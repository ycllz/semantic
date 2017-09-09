{-# LANGUAGE DataKinds, GADTs, MultiParamTypeClasses, TypeOperators #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}
module Renderer.JSON
( renderJSONDiff
, renderJSONTerm
) where

import Data.Aeson (ToJSON, toJSON, encode, object, (.=))
import Data.Aeson as A hiding (json)
import Data.Blob
import Data.ByteString.Lazy (toStrict)
import Data.Foldable (toList)
import Data.Functor.Both (Both)
import qualified Data.Map as Map
import Data.Output
import Data.Semigroup ((<>))
import Data.Text (Text)
import Data.Text.Encoding (decodeUtf8)
import GHC.Generics
import Language

--
-- Diffs
--

-- | Render a diff to a string representing its JSON.
renderJSONDiff :: ToJSON a => Both Blob -> a -> Map.Map Text Value
renderJSONDiff blobs diff = Map.fromList
  [ ("diff", toJSON diff)
  , ("oids", toJSON (decodeUtf8 . blobOid <$> toList blobs))
  , ("paths", toJSON (blobPath <$> toList blobs))
  ]

data File a = File { filePath :: FilePath, fileLanguage :: Maybe Language, fileContent :: a }
  deriving (Generic, Show)

instance ToJSON a => ToJSON (File a) where
  toJSON File{..} = object [ "filePath" .= filePath, "language" .= fileLanguage, "programNode" .= fileContent ]

instance Output [Value] where
  toOutput = toStrict . (<> "\n") . encode

renderJSONTerm :: ToJSON a => Blob -> a -> [Value]
renderJSONTerm Blob{..} = pure . toJSON . File blobPath blobLanguage
