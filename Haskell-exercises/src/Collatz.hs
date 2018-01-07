-- Experiments on Collatz's conjecture
module Collatz where

import Data.Maybe
import Data.Bool.HT
import Data.Graph.Inductive.Graph
import Data.Graph.Inductive.PatriciaTree
import Data.Tree
import Data.Char
import Data.List

primeFactors :: Integer -> [Integer]
primeFactors 1 = []
primeFactors n
  | factors == []  = [n]
  | otherwise = factors ++ primeFactors (n `div` (head factors))
  where factors = take 1 $ filter (\x -> (n `mod` x) == 0) [2 .. n-1]

times3plus1 :: Integer -> Integer
times3plus1 n = 3 * n + 1

div2 :: Integer -> Maybe Integer
div2 n 
  | n == 0 = Nothing
  | odd n = Nothing
  | otherwise = Just (n `div` 2)

reverseDiv2 :: Integer -> Integer
reverseDiv2 n = n * 2

reverseTimes3Plus1 :: Integer -> Maybe Integer
reverseTimes3Plus1 n
  | (n - 1) == 0 = Nothing
  | (n - 1) `mod` 3 /= 0 = Nothing
  | otherwise = Just ((n - 1) `div` 3)

collatzDownwardSeries :: Integer -> [Integer]
collatzDownwardSeries n = 
  let next = div2 n
  in [n] ++ collatzDownwardSeries (fromMaybe (times3plus1 n) next)
  
data CollatzElement = JustReverseDiv2 Integer | BothExpressions Integer Integer | Endless Integer deriving (Show)

nextCollatz :: Integer -> CollatzElement
nextCollatz n
  | isEndless  = Endless next2
  | hasNoNext3 = JustReverseDiv2 next2
  | otherwise  = BothExpressions next2 next3
  where next3Maybe = reverseTimes3Plus1 n
        hasNoNext3 = isNothing (next3Maybe)
        isEndless  = hasNoNext3 && (n `mod` 3 == 0)
        next2      = reverseDiv2 n
        next3      = fromMaybe 0 (next3Maybe)
 
collatzElementToArray :: CollatzElement -> [Integer]
collatzElementToArray (JustReverseDiv2 a)   = [a]
collatzElementToArray (Endless a)           = [a]
collatzElementToArray (BothExpressions a b) = [a, b]

nextCollatzArray :: Integer -> [Integer]
nextCollatzArray = collatzElementToArray . nextCollatz

collatzFirstRightSeries :: Integer -> [Integer]
collatzFirstRightSeries n = n : (collatzFirstRightSeries . last . nextCollatzArray) n

collatzTree :: Integer -> Tree Integer
collatzTree n = unfoldTree (\x -> (x, nextCollatzArray x)) n

collatzUpwards :: Integer -> (Integer, CollatzElement)
collatzUpwards n = (n, nextCollatz n)

collatzToEdges :: (Integer, CollatzElement) -> (LNode String, [LEdge String])
collatzToEdges (from, Endless to) = ((fromInt, show from), [(fromInt, toInt, label)])
  where fromInt = fromIntegral from
        toInt   = fromIntegral to
        label   = "endless"
collatzToEdges (from, JustReverseDiv2 to) = ((fromInt, show from), [(fromInt, toInt, label)])
  where fromInt = fromIntegral from
        toInt   = fromIntegral to
        label   = "x*2"
collatzToEdges (from, BothExpressions to1 to2) = ((fromInt, show from), [(fromInt, toInt1, label1), (fromInt, toInt2, label2)])
  where fromInt = fromIntegral from
        toInt1  = fromIntegral to1
        toInt2  = fromIntegral to2
        label1  = "x*2"
        label2  = "(x-1)/3"

collatzUpwardsToEdges :: Integer -> (LNode String, [LEdge String])
collatzUpwardsToEdges = collatzToEdges . collatzUpwards

addNodesAndEdges :: Gr String String -> (LNode String, [LEdge String]) -> Gr String String
addNodesAndEdges g n = insEdges (snd n) (insNode (fst n) g)

collatzGraph :: Integer -> Gr String String
collatzGraph n = foldl (\g n -> addNodesAndEdges g . collatzUpwardsToEdges $ n) empty [1..n]

collatzSequences n = mapM print $ map collatzDownwardSeries [1..n]
collatzUpwardSequences n = mapM print $ map collatzUpwards [1..n]

bitArray 0 = []
bitArray n = 
  let (q,r) = n `divMod` 2 
      rs    = intToDigit r
  in rs : bitArray q

toBin n = reverse (bitArray n)

applyAll :: [(Integer -> String)] -> Integer -> [String]
applyAll a n = map (\f -> f n) a

pad n = (\x -> replicate (n - length x) ' ' ++ x)

removeLead ('0':xs) = removeLead xs
removeLead x = x
removeTrail = reverse . removeLead . reverse

auxDoItFgt = applyAll [dec2, b, n3, b3, dNext, bNext, dNextOdd, bNextOdd, factors, nextFactors]
  where c           = collatzDownwardSeries
        toBinPad n  = pad n . toBin . fromIntegral
        maxElement  = 999 :: Integer
        digitsDec   = (length . show) maxElement
        digitsDecNx = digitsDec + 1
        digitsBin   = ceiling (logBase (fromInteger 2) (fromInteger maxElement))
        digitsBinNx = digitsBin + 3
        dec2        = pad digitsDec . show
        dec3        = pad digitsDecNx . show
        b           = toBinPad digitsBin
        n3          = dec2 . (*3)
        b3          = toBinPad digitsBinNx . (*3)
        next        = head . tail . c
        dNext       = dec3 . next
        bNext       = toBinPad digitsBinNx . next
        nextOdd     = fromJust . find odd . tail . tail . c
        dNextOdd    = dec3 . nextOdd
        bNextOdd    = toBinPad digitsBinNx . nextOdd
        factors     = show . primeFactors
        nextFactors = show . primeFactors . nextOdd

doItFgt = (filter ((==0) . length . last) . map (auxDoItFgt . (+1) . (*2))) [0..]

exploreFactors = mapM (print . applyAll [pad 10 . show, show . primeFactors]) . filter odd . takeWhile (/=1) . collatzDownwardSeries