module Elmi
  ( for
  , toModuleName
  ) where

import qualified Data.Maybe as M
import qualified Data.Text as T
import qualified Elm.Json
import Elm.Json (ElmJson(..))
import Prelude hiding (all)
import Subset (Subset(..))
import System.FilePath
       (FilePath, (<.>), (</>), dropExtension, splitDirectories,
        takeFileName)
import System.FilePath.Extra (findAll, maybeMakeRelative)

toModuleName :: FilePath -> T.Text
toModuleName = T.replace "-" "." . T.pack . dropExtension . takeFileName

for :: Subset FilePath -> IO [FilePath]
for subset = do
  ElmJson {elmVersion, sourceDirecotries} <- Elm.Json.load
  case subset of
    All -> findAll "elmi" (elmStuff elmVersion)
    Subset modulePaths ->
      return
        (toElmiPath elmVersion . removeSourceDir sourceDirecotries <$>
         modulePaths)

toElmiPath :: T.Text -> FilePath -> FilePath
toElmiPath version modulePath
  -- TODO find elm root (elm.json)
 = elmStuff version </> T.unpack (dasherize modulePath) <.> "elmi"

elmStuff :: T.Text -> FilePath
elmStuff version = "elm-stuff" </> T.unpack version

removeSourceDir :: [FilePath] -> FilePath -> FilePath
removeSourceDir dirs file =
  M.fromMaybe file $ M.listToMaybe $ M.mapMaybe (maybeMakeRelative file) dirs

dasherize :: FilePath -> T.Text
dasherize = T.intercalate "-" . fmap T.pack . splitDirectories . dropExtension
