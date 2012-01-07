-----------------------------------------------------------------------------
--
-- Module      :  Main
-- Copyright   :
-- License     :  AllRightsReserved
--
-- Maintainer  :
-- Stability   :
-- Portability :
--
-- |
--
-----------------------------------------------------------------------------

{-# LANGUAGE
      TemplateHaskell
    , QuasiQuotes
    , OverloadedStrings
    , GADTs
    , NoMonomorphismRestriction
    , TypeFamilies
    , MultiParamTypeClasses
    #-}

module Main (
    main
) where

import Data.Char
import Data.List
import qualified Data.Text as T
import Data.Text (Text)
import Data.Time (Day)

import Control.Applicative
import Control.Arrow

import Yesod
import Yesod.Form.Jquery
import Text.Hamlet
import Text.Blaze.Renderer.String

import Database.Persist
import Database.Persist.TH
import qualified Database.Persist.Sqlite as DBS

data Links = Links DBS.ConnectionPool

instance Yesod Links where
    approot _ = ""

instance RenderMessage Links FormMessage where
    renderMessage _ _ = defaultFormMessage

instance YesodJquery Links

instance YesodPersist Links where
    type YesodPersistBackend Links = DBS.SqlPersist

    runDB action = liftIOHandler $ do
        Links pool <- getYesod
        DBS.runSqlPool action pool

data PersonA = PersonA
    { name :: String
    , age  :: Int
    }

data Person = Person
    { personName          :: Text
    , personBirthday      :: Day
    , personFavoriteColor :: Color
    , personEmail         :: Text
    , personWebsite       :: Maybe Text
    }
  deriving Show

data Color = Red | Blue | Gray | Black
    deriving (Show, Eq, Enum, Bounded)

share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persist|
PersonP
    name String
    age Int
|]

mkYesod "Links" [parseRoutes|
/person/#Text                       PersonR  GET
/year/#Integer/month/#Text/day/#Int DateR
/wiki/*Texts                        WikiR    GET
/                                   HomeR    GET
/page1                              Page1R   GET
/page2                              Page2R   GET
/personF                            PersonFR POST
|]

getPersonR :: Text -> Handler RepHtml
getPersonR name = (liftIO . putStrLn $ show name) >> defaultLayout [whamlet|<h1>Hello #{name}!|]

handleDateR :: Integer -> Text -> Int -> Handler RepPlain
handleDateR year month day =
    return $ RepPlain $ toContent $
        T.concat [month, " ", T.pack $ show day, ", ", T.pack $ show year]

getWikiR :: [Text] -> Handler RepPlain
getWikiR = return . RepPlain . toContent . T.unwords

getHomeR :: Handler RepHtml
getHomeR = do
    ((_, widget), enctype) <- generateFormPost personForm
    dbs <- runDB . DBS.insert $ PersonP "Michael" 26
    dbm <- runDB $ DBS.get dbs
    defaultLayout $ do
        setTitle "boo"
        [whamlet|
<p>The widget generated contains only the contents of the form, not the form tag itself. So...
<p>It also doesn't include the submit button.
^{pst PersonFR widget enctype}
Go to #
<a href=@{Page1R}>page 1
!
^{toWidget $ stuff $ PersonA "Michael" 26}
<p>dbstuff: #{show dbs} #{show dbm} -- how factor out show?
|]

getPage1R = defaultLayout [whamlet|<a href=@{Page2R}>Go to page 2!|]
getPage2R = defaultLayout [whamlet|<a href=@{HomeR }>Go home!     |]

postPersonFR :: Handler RepHtml
postPersonFR = do
    ((result, widget), enctype) <- runFormPost personForm
    case result of
        FormSuccess person -> defaultLayout [whamlet|<p>#{show person}|]
        _                  -> defaultLayout [whamlet|
<p>Invalid input, let's try again.
^{pst PersonFR widget enctype}
|]

stuff person = [shamlet|
<p>Hello, my name is #{name person} and I am #{show $ age person}.
<p>Let's do some funny stuff with my name: #
    <b>#{sort $ map toLower (name person)}
<p>Oh, and in 5 years I'll be #{show $ (+) 5 (age person)} years old.
|]

personForm :: Html -> Form Links Links (FormResult Person, Widget)
personForm = renderDivs $ Person
    <$> areq textField  "Name"              Nothing
    <*> areq (jqueryDayField def
        { jdsChangeYear = True      -- give a year dropdown
        , jdsYearRange = "1900:-5"  -- 1900 till five years ago
        })              "Birthday"          Nothing
    <*> areq (selectField colors)  "Favorite color"    Nothing
    <*> areq emailField "Email address"     (Just "blah")
    <*> aopt urlField   "Website"           Nothing
    where colors =  map (T.pack . show &&& id) [minBound..maxBound]

pst t w e = [whamlet|
<form method=post action=@{t} enctype=#{e}>
    ^{w}
    <input type=submit>
|]

(>*>) :: (Applicative f, Monad m) => f (m a) -> f (m b) -> f (m b)
(>*>) = liftA2 (>>) -- = (>>) <$> f <*> g
(<*<) = flip (>*>)

main = DBS.withSqlitePool ":memory:" 10 $ \pool -> do
    out <- flip DBS.runSqlPool pool $ do
         DBS.printMigration >*> DBS.runMigration $ migrateAll
         DBS.insert $ PersonP "Michael" 26
    liftIO $ print out
    warpDebug 3000 $ Links pool
