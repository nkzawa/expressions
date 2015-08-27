import qualified Control.Monad as Monad
import qualified Data.ByteString as ByteString
import qualified Data.Char as Char
import qualified Data.List as List
import qualified Data.Map as Map
import qualified Data.Maybe as Maybe
import qualified Data.Tuple as Tuple
import qualified Data.Ord as Ord
import qualified Data.Word as Word
import qualified Numeric

data Node =
  LeafNode { weight :: Int, symbol :: Char } |
  InternalNode { weight :: Int, left :: Node, right :: Node }
  deriving (Show, Eq, Ord)

eof = Char.chr 255

createTable :: String -> [(Char, String)]
createTable = generateCodes
  . head
  . until (null . tail) insertInternalNode
  . List.sortBy compareWeight
  . map (\x -> LeafNode { weight = length x, symbol = head x })
  . List.group
  . List.sort

compareWeight :: Node -> Node -> Ordering
compareWeight = Ord.comparing weight

insertInternalNode :: [Node] -> [Node]
insertInternalNode (x1:x2:xs) =
  List.insertBy compareWeight InternalNode {
    weight = weight x1 + weight x2,
    left = x1,
    right = x2
  } xs

generateCodes :: Node -> [(Char, String)]
generateCodes LeafNode { symbol = s } = [(s, "")]
generateCodes InternalNode { left = l, right = r } =
  generateCodes' '0' l ++ generateCodes' '1' r

generateCodes' :: Char -> Node -> [(Char, String)]
generateCodes' p n = map (\(a, b) -> (a, p:b)) (generateCodes n)

encode :: [(Char, String)] -> String -> Maybe ByteString.ByteString
encode t = fmap ByteString.pack
  . Monad.join
  . fmap (mapM (readBin . rpad 8) . chunksOf 8 . concat)
  . mapM (`Map.lookup` m)
  where m = Map.fromList t

decode :: [(Char, String)] -> ByteString.ByteString -> Maybe String
decode t = parse m
  . concat
  . map (lpad 8 . showBin)
  . ByteString.unpack
  where m = Map.fromList . map Tuple.swap $ t

lpad :: Int -> String -> String
lpad n s
  | l < n = replicate (n - l) '0' ++ s
  | otherwise = s
  where l = length s

rpad :: Int -> String -> String
rpad n s
  | l < n = s ++ replicate (n - l) '0'
  | otherwise = s
  where l = length s

chunksOf :: Int -> [a] -> [[a]]
chunksOf _ [] = []
chunksOf n xs = a:(chunksOf n b)
  where (a, b) = splitAt n xs

readBin :: String -> Maybe Word.Word8
readBin = fmap fst
  . Maybe.listToMaybe
  . Numeric.readInt 2 (`elem` "01") Char.digitToInt

showBin :: Word.Word8 -> String
showBin n = Numeric.showIntAtBase 2 Char.intToDigit n ""

parse :: Map.Map String Char -> String -> Maybe String
parse m x = fmap init
  . fst
  . until' (fmap (elem eof) . fst)
    (\(a, b) -> let (c, d) = parse'' b in ((\a b -> a ++ [b]) <$> a <*> c, d))
  $ (Just "", x)
  where parse'' = parse' m

parse' :: Map.Map String Char -> String -> (Maybe Char, String)
parse' m x = (\(a, b) -> (Map.lookup a m, b))
  . until ((`Map.member` m) . fst) (\(a, b) -> (a ++ [head b], tail b))
  $ ("", x)

until' :: (a -> Maybe Bool) -> (a -> a) -> a -> a
until' p f = go
  where
    go x = case p x of
      Just True -> x
      _ -> go (f x)

main = do
  input <- getContents
  let input' = input ++ [eof]
  let table = createTable input'
  let encoded = encode table input'
  let decoded = decode table $ Maybe.fromJust encoded
  putStr $ Maybe.fromJust decoded
