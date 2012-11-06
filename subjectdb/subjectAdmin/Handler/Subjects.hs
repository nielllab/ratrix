module Handler.Subjects where

import Import
import CRUDGrid
import qualified Data.Text as T
import Data.Maybe
import System.FilePath
import Data.List.Split
-- import Data.Text.IO (readFile)
import System.Process
import Control.Monad
import Text.Parsec
import Text.ParserCombinators.Parsec.Number
import Text.Parsec.String
import Data.Char
import Control.Arrow
import System.Exit
import Data.List (intercalate, nub, (\\))
import qualified Data.Conduit as C
import qualified Data.Conduit.List as CL
import Prelude (last)
import Data.Function
import Data.List hiding (insert)
import GHC.Exts

type SubjectParse = (Text, Text, Text, Double, Double)

info :: Parser [SubjectParse]
info = do
    manyTill anyChar . try . onLine $ string "BEGIN OUTPUT"
    manyTill good eof

good :: Parser SubjectParse
good = skipTill bad . try . onLine $ do
    station <- word
    dir <- between (char '"') (char '"') . many $ satisfy (\x -> and $ [isPrint, (/='"')] <*> [x])
    spaces1
    subj <- word
    string "reward:"
    reward <- fractional3 False
    spaces1
    string "pnlty:"
    penalty <- fractional3 False
    return (station, T.pack dir, subj, reward, penalty)

bad = choice $ startLine <$> ["umount", "none for"]

startLine x = string x >> tilLine anyChar
    
word :: Parser Text
word = T.pack <$> (manyTill anyChar $ try spaces1)

spaces1 = skipMany1 space

tilLine x = manyTill x $ try newline

onLine x = do
    out <- x
    newline
    return out

skipTill x end = end <|> (x >> skipTill x end)

populate :: ( PersistQuery (YesodPersistBackend m) (GHandler s m)
            , YesodPersist m
            , Yesod m
            , PersistUnique (YesodPersistBackend m) (GHandler s m)
            )
         => [SubjectParse]
         -> GWidget s m ()
populate entries = do
    (oldStationsD, newStations) <- lift $ getAll stationRecName $ getStation <$> entries
    newStationIds <- lift $ mapM runDB $ insert . StationRec <$> newStations
    let stationD = oldStationsD ++ zip newStations newStationIds    
        (dupes,goods) = findDups getSubject entries
        noDupe = (last <$> dupes) ++ goods
    lift $ mapM_ (updateSub stationD) noDupe
    [whamlet|
$forall d <- dupes
    warning: found dupe (last wins) <br>
    $forall t <- d
        #{show t} <br> 
    <br>
<br>
|]

findDups f = (second concat) . partition ((> 1) . length) . groupWith f

getAll f xs = do
    old <- runDB $ selectList [] []
    let newVals = nub $ xs
        oldVals = f . entityVal <$> old
        news = newVals \\ oldVals    
--    liftIO $ mapM_ print news
    return (zip oldVals $ entityKey <$> old, news)

updateSub stations x = do
    let sub = Subject (getSubject x)
                      (getReward x)
                      (fromJust $ lookup (getStation x) stations)
                      $ getDir x
{-
    match <- runDB $ selectKeysList [SubjectName ==. subjectName sub]
    case match of
        []   -> void . runDB $ insert sub
        [id] -> runDB $ replace id sub
-}
    match <- runDB . getBy . UniqueSubject $ subjectName sub
    runDB $ maybe (const () <$> insert sub) (flip replace sub . entityKey) match

selectKeysList :: ( PersistEntity p
                  , PersistQuery b m
                  ) 
               => [Filter p] 
               -> b m [Key b p]
selectKeysList f = C.runResourceT $ selectKeys f [] C.$$ CL.consume

getStation (x,_,_,_,_) = x
getSubject(_,_,x,_,_) = x
getReward(_,_,_,x,_) = x
getDir(_,x,_,_,_) = x

getPopulateR ::
            ( PersistQuery (YesodPersistBackend m) (GHandler s m)
            , YesodPersist m
            , Yesod m
            , PersistUnique (YesodPersistBackend m) (GHandler s m)
            )
         => GHandler s m RepHtml
getPopulateR = defaultLayout $ do
    (report, success, entries) <- liftIO $ do
--      (exitcode, stdout, stderr) <- readProcessWithExitCode "octave" ["--no-window-system", "--no-site-file", "-q", "-p" ++ rPath] ("GetSecs," ++ cmds)
        (exitcode, stdout, stderr) <- readProcessWithExitCode "matlab" ["-nojvm", "-nodesktop", "-nodisplay", "-nosplash"] cmds

        let entries = parse info "" stdout
            success = ((const False ||| const True) entries) && exitcode == ExitSuccess && null stderr
            report = splitOn "\n" $ "exit:\n" ++ (show exitcode) ++ 
                                "\n\nstderr:\n" ++ stderr ++ 
                                "\n\nparse:\n" ++ ((show ||| unlines . (show <$>)) entries) ++ 
                                "\n\nstdout:\n" ++ (numLines stdout)
        return (report, success, (undefined ||| id) entries)
    when success $ populate entries
    [whamlet|
$forall s <- report
    #{s} <br>
|]
    setTitle "populate"

numLines = unlines . zipWith (\x -> ((show x ++ ":") ++)) [1..] . lines

rPath = "\"/home/nlab/ratrix/bootstrap\""
cmds = concat
    [ "cd /home/nlab/ratrix/bootstrap,"
    , "setupEnvironment,"
    , "collectInfo,"
    , "quit"
    ]

{-
matlab -nodisplay -nosplash -nojvm -nodesktop -r "GetSecs,cd('/home/nlab/ratrix/bootstrap'),setupEnvironment,collectInfo,quit"
-}

{-
mntpt = "/mnt/tmp"
cmds = concat [ "system 'sudo mkdir " ++ mntpt ++ "',"
              , "system 'sudo mount.cifs //184.171.85.60/Users " ++ mntpt ++ " -o username=workgroup/nlab,password=huestis238',"
              , "dir " ++ mntpt ++ "/nlab/Desktop/mouseData/ServerData,"
              , "system 'sudo umount " ++ mntpt ++ "',"
              , "system 'sudo rmdir " ++ mntpt ++ "'"
              ]
-}

{-
"-logfile", log, "-sd", matlabDir

  --exec-path PATH        Set path for executing subprograms.  
  --path PATH, -p PATH    Add PATH to head of function search path.

  --traditional           Set variables for closer MATLAB compatibility.

  FILE                    Execute commands from FILE.  Exit when done
                          unless --persist is also specified.
-}

getSubjectsR :: Handler RepHtml
getSubjectsR = groupGet subjectGrid

getSubjectR, postSubjectR :: SubjectId -> Handler RepHtml
getSubjectR  = formGet subjectGrid
postSubjectR = formPost subjectGrid

data SubjectColumn = Station | Dir | Name | Reward
   deriving (Eq, Show, Bounded, Enum)

subjectGrid :: Grid s App Subject SubjectColumn
subjectGrid = Grid "Subjects" False Nothing (Routes SubjectR SubjectsR undefined undefined) $ \c -> case c of 
    Station -> GridField show subjectStation show -- (T.unpack . stationRecName . entityVal . fromJust . runDB . get)
                                                      Nothing
    Dir     -> GridField show subjectDir     T.unpack Nothing
    Name    -> GridField show subjectName    T.unpack Nothing
    Reward  -> GridField show subjectReward  show   . Just $ Editable rewardField SubjectReward True (\x y -> y{subjectReward = x})

rewardField :: Field s App Double
rewardField = checkBool (>= 0) rewardMsg doubleField

rewardMsg :: Text
rewardMsg = "reward must be >= 0"
