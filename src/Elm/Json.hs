module Elm.Json
  ( ElmJson(..)
  , load
  ) where

import Control.Exception.Safe
import qualified Data.Aeson as Aeson
import Data.Aeson ((.:))
import qualified Data.ByteString.Lazy as BL
import Data.Semigroup ((<>))
import qualified Data.Text as T
import Data.Typeable (Typeable, cast)
import System.FilePath (FilePath, (<.>), (</>))

data ElmJson = ElmJson
  { sourceDirecotries :: [FilePath]
  , elmVersion :: T.Text
  }

instance Aeson.FromJSON ElmJson where
  parseJSON =
    Aeson.withObject "Coord" $ \v ->
      ElmJson <$> v .: "source-directories" <*> v .: "elm-version"

load :: FilePath -> IO ElmJson
load root = do
  let elmJsonPath = (root </> "elm" <.> "json")
  contents <- BL.readFile elmJsonPath
  case Aeson.eitherDecode contents of
    Right json -> return json
    Left _ -> throwM (DecodingElmJsonFailed elmJsonPath)

newtype DecodingElmJsonFailed =
  DecodingElmJsonFailed FilePath
  deriving (Typeable)

instance Show DecodingElmJsonFailed where
  show (DecodingElmJsonFailed path) = "Couldn't decode " <> path

instance Exception DecodingElmJsonFailed where
  toException = toException . SomeAsyncException
  fromException se = do
    SomeAsyncException e <- fromException se
    cast e
