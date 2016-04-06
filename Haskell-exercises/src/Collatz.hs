-- Experiments on Collatz's conjecture
module Collatz where

data CollatzNumber = DivideByTwo Integer | TriplePlusOne Integer

collatzDownwardSeries :: Integer -> [Integer]
collatzDownwardSeries 1 = [1]
collatzDownwardSeries 2 = [2, 1]
collatzDownwardSeries 3 = [3, 10, 5, 16, 8, 4, 2, 1]
collatzDownwardSeries n = [n] ++ collatzDownwardSeries (if even n then (n `div` 2) else (3 * n + 1))

collatzSequences = mapM print $ map collatzDownwardSeries [1..]