{-# LANGUAGE MultiParamTypeClasses #-}
module Renderer.Patch
( renderPatch
, File(..)
, hunks
, Hunk(..)
, truncatePatch
import Data.Blob
import qualified Data.ByteString.Char8 as ByteString
import Data.Range
import Data.Source
truncatePatch :: Both Blob -> ByteString
truncatePatch blobs = header blobs <> "#timed_out\nTruncating diff: timeout reached.\n"
renderPatch :: (HasField fields Range, Traversable f) => Both Blob -> Diff f (Record fields) -> File
renderPatch blobs diff = File $ if not (ByteString.null text) && ByteString.last text /= '\n'
  then text <> "\n\\ No newline at end of file\n"
  else text
  where text = header blobs <> mconcat (showHunk blobs <$> hunks diff blobs)

newtype File = File { unFile :: ByteString }
  deriving Show

instance Monoid File where
  mempty = File mempty
  mappend (File a) (File b) = File (a <> "\n" <> b)

instance StringConv File ByteString where
  strConv _ = unFile

showHunk :: Functor f => HasField fields Range => Both Blob -> Hunk (SplitDiff f (Record fields)) -> ByteString
  mconcat (showChange sources <$> changes hunk) <>
  where sources = blobSource <$> blobs
showChange :: Functor f => HasField fields Range => Both Source -> Change (SplitDiff f (Record fields)) -> ByteString
showLines :: Functor f => HasField fields Range => Source -> Char -> [Maybe (SplitDiff f (Record fields))] -> ByteString
        prepend source = ByteString.singleton prefix <> source
showLine :: Functor f => HasField fields Range => Source -> Maybe (SplitDiff f (Record fields)) -> Maybe ByteString
showLine source line | Just line <- line = Just . sourceBytes . (`slice` source) $ getRange line
header :: Both Blob -> ByteString
header blobs = ByteString.intercalate "\n" ([filepathHeader, fileModeHeader] <> maybeFilepaths) <> "\n"
          (Nothing, Just mode) -> ByteString.intercalate "\n" [ "new file mode " <> modeToDigits mode, blobOidHeader ]
          (Just mode, Nothing) -> ByteString.intercalate "\n" [ "deleted file mode " <> modeToDigits mode, blobOidHeader ]
          (Just mode1, Just mode2) -> ByteString.intercalate "\n" [
        modeHeader :: ByteString -> Maybe BlobKind -> ByteString -> ByteString
        maybeFilepaths = if (nullOid == oidA && nullSource (snd sources)) || (nullOid == oidB && nullSource (fst sources)) then [] else [ beforeFilepath, afterFilepath ]
        sources = blobSource <$> blobs
        (pathA, pathB) = case runJoin $ toS . blobPath <$> blobs of
        (oidA, oidB) = runJoin $ blobOid <$> blobs
hunks :: (Traversable f, HasField fields Range) => Diff f (Record fields) -> Both Blob -> [Hunk (SplitDiff [] (Record fields))]
hunks _ blobs | sources <- blobSource <$> blobs
              , sourcesNull <- runBothWith (&&) (nullSource <$> sources)
hunks diff blobs = hunksInRows (pure 1) $ alignDiff (blobSource <$> blobs) diff