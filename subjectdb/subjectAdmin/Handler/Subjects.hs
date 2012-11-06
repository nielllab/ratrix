module Handler.Subjects where

import Import
import Prelude (last)
import Data.Maybe
import Data.List hiding (insert)
import Data.List.Split
import GHC.Exts
import qualified Data.Text as T
-- import Data.Text.IO (readFile)
import Control.Monad
import Control.Arrow
import System.Exit
import System.Process
--import System.FilePath
import Text.Parsec
import Text.ParserCombinators.Parsec.Number
import Text.Parsec.String
import Data.Char
import CRUDGrid
import qualified Data.Conduit as C
import qualified Data.Conduit.List as CL

type SubjectParse = (Text, Text, Text, Double, Double)

info :: Parser [SubjectParse]
info = do
    void . manyTill anyChar . try . onLine $ string "BEGIN OUTPUT"
    manyTill good eof

good :: Parser SubjectParse
good = skipTill bad . try . onLine $ do
    station <- word
    dir <- between (char '"') (char '"') . many $ satisfy (\x -> and $ [isPrint, (/='"')] <*> [x])
    void $ spaces1
    subj <- word
    void $ string "reward:"
    reward <- fractional3 False
    void $ spaces1
    void $ string "pnlty:"
    penalty <- fractional3 False
    return (station, T.pack dir, subj, reward, penalty)

bad :: Parser String
bad = choice $ startLine <$> ["umount", "none for"]

startLine :: String -> Parser String
startLine x = string x >> tilLine anyChar
    
word :: Parser Text
word = T.pack <$> (manyTill anyChar $ try spaces1)

spaces1 :: Parser ()
spaces1 = skipMany1 space

tilLine :: Parser a -> Parser [a]
tilLine x = manyTill x $ try newline

onLine :: Parser a -> Parser a
onLine x = do
    out <- x
    void $ newline
    return out

skipTill :: Parser a -> Parser b -> Parser b
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

findDups :: Ord b => (a -> b) -> [a] -> ([[a]], [a])
findDups f = (second concat) . partition ((> 1) . length) . groupWith f

getAll :: ( Eq a
          , PersistEntity val
          , YesodPersist m
          , PersistQuery (YesodPersistBackend m) (GHandler s m)
          , PersistEntityBackend val ~ YesodPersistBackend m
          ) 
       => (val -> a)
       -> [a]
       -> GHandler s m ([(a, Key (YesodPersistBackend m) val)], [a])
getAll f xs = do
    old <- runDB $ selectList [] []
    let newVals = nub $ xs
        oldVals = f . entityVal <$> old
        news = newVals \\ oldVals    
    return (zip oldVals $ entityKey <$> old, news)

updateSub :: ( YesodPersist m
             , PersistUnique (YesodPersistBackend m) (GHandler s m)
             ) 
          => [(Text, Key (YesodPersistBackend m) (StationRecGeneric (YesodPersistBackend m)))]
          -> SubjectParse
          -> GHandler s m ()
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
    runDB $ maybe (void $ insert sub) (flip replace sub . entityKey) match

selectKeysList :: ( PersistEntity p
                  , PersistQuery b m
                  ) 
               => [Filter p] 
               -> b m [Key b p]
selectKeysList f = C.runResourceT $ selectKeys f [] C.$$ CL.consume

getStation :: SubjectParse -> Text
getStation (x,_,_,_,_) = x

getDir     :: SubjectParse -> Text
getDir     (_,x,_,_,_) = x

getSubject :: SubjectParse -> Text
getSubject (_,_,x,_,_) = x

getReward  :: SubjectParse -> Double
getReward  (_,_,_,x,_) = x

getPopulateR ::
            ( PersistQuery (YesodPersistBackend m) (GHandler s m)
            , YesodPersist m
            , Yesod m
            , PersistUnique (YesodPersistBackend m) (GHandler s m)
            )
         => GHandler s m RepHtml
getPopulateR = defaultLayout $ do
    (report, success, entries) <- liftIO $ do
--      (exitcode, stdout, stderr) <- readProcessWithExitCode "octave" ["--no-window-system", "--no-site-file", "-q", "-p" ++ rPath] cmds
        (exitcode, stdout, stderr) <- readProcessWithExitCode "matlab" ["-nojvm", "-nodesktop", "-nodisplay", "-nosplash"] cmds
        let entries = parse info "" stdout
            success = ((const False ||| const True) entries) && exitcode == ExitSuccess && null stderr
            report = splitOn "\n" $ 
                        "exit:\n" ++ (show exitcode) ++ 
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

numLines :: String -> String
numLines = unlines . zipWith (\x -> ((show x ++ ":") ++)) ([1..]::[Int]) . lines

rPath :: String --Text
rPath = "\"/home/nlab/ratrix/bootstrap\""

cmds :: String -- Text
cmds = concat
    [ "cd " ++ rPath ++ ","
    , "setupEnvironment,"
    , "collectInfo,"
    , "quit"
    ]

getSubjectsR :: Handler RepHtml
getSubjectsR = groupGet subjectGrid

getSubjectR, postSubjectR :: SubjectId -> Handler RepHtml
getSubjectR  = formGet subjectGrid
postSubjectR = formPost subjectGrid

data SubjectColumn = Station | Dir | Name | Reward
   deriving (Eq, Show, Bounded, Enum)

subjectGrid :: Grid s App Subject SubjectColumn
subjectGrid = Grid "Subjects" [Asc SubjectStation, Asc SubjectDir, Asc SubjectName] False Nothing (Routes SubjectR SubjectsR undefined undefined) $ \c -> case c of 
    Station -> GridField show subjectStation (Right $ showFieldByID Nothing T.unpack stationRecName)
                                                             Nothing
    Dir     -> GridField show subjectDir     (Left T.unpack) Nothing
    Name    -> GridField show subjectName    (Left T.unpack) Nothing
    Reward  -> GridField show subjectReward  (Left show)   . Just $ Editable rewardField SubjectReward True (\x y -> y{subjectReward = x})

rewardField :: Field s App Double
rewardField = checkBool (>= 0) rewardMsg doubleField

rewardMsg :: Text
rewardMsg = "reward must be >= 0"
