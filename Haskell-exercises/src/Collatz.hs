-- Experiments on Collatz's conjecture
module Collatz where

import Data.Maybe
import Data.Bool.HT
import Data.Graph.Inductive.Graph
import Data.Graph.Inductive.PatriciaTree

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
collatzDownwardSeries 1 = [1]
collatzDownwardSeries 2 = [2, 1]
collatzDownwardSeries 3 = [3, 10, 5, 16, 8, 4, 2, 1]
collatzDownwardSeries n = 
  let next = div2 n
  in [n] ++ collatzDownwardSeries (fromMaybe (times3plus1 n) next)
  
data CollatzElement = JustReverseDiv2 Integer | BothExpressions Integer Integer deriving (Show)

nextCollatz :: Integer -> CollatzElement
nextCollatz n
  | isNothing (reverseTimes3Plus1 n) = JustReverseDiv2 (reverseDiv2 n)
  | otherwise                        = BothExpressions (reverseDiv2 n) (fromJust (reverseTimes3Plus1 n))
  
collatzUpwards :: Integer -> (Integer, CollatzElement)
collatzUpwards n = (n, nextCollatz n)

collatzToEdges :: (Integer, CollatzElement) -> (LNode String, [LEdge String])
collatzToEdges (from, JustReverseDiv2 to) = ((fromIntegral from, show from), [(fromIntegral from, fromIntegral to, "x*2")])
collatzToEdges (from, BothExpressions to1 to2) = ((fromIntegral from, show from), [(fromIntegral from, fromIntegral to1, "x*2"), (fromIntegral from, fromIntegral to2, "(x-1)/3")])

collatzUpwardsToEdges :: Integer -> (LNode String, [LEdge String])
collatzUpwardsToEdges = collatzToEdges . collatzUpwards

addNodesAndEdges :: Gr String String -> (LNode String, [LEdge String]) -> Gr String String
addNodesAndEdges g n = insEdges (snd n) (insNode (fst n) g)

collatzGraph :: Integer -> Gr String String
collatzGraph n = foldl (\g n -> addNodesAndEdges g . collatzUpwardsToEdges $ n) empty [1..n]

collatzSequences = mapM print $ map collatzDownwardSeries [1..]
