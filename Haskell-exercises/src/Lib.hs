module Lib
(
  problem1
) where

import qualified Data.Set as Set

-- Problems from https://projecteuler.net
-- https://projecteuler.net/problem=1
problem1 = 
  let mults3 = takeWhile (<1000) (map (*3) [1..])
      mults5 = takeWhile (<1000) (map (*5) [1..])
  in sum (Set.fromList (concat [mults3, mults5]))

-- https://projecteuler.net/problem=2
problem2 = 
  let fibs = takeWhile (<4000000) (0 : 1 : zipWith (+) fibs (tail fibs))
  in sum (filter (even) fibs)

generatePrimes :: [Int]
generatePrimes = 2 : primes'
  where isPrime (p:ps) n = p*p > n || n `rem` p /= 0 && isPrime ps n
        primes' = 3 : filter (isPrime primes') [5, 7 ..]

-- https://projecteuler.net/problem=3
problem3 :: Int -> Int
problem3 factorize =
  let primeFactors = (filter (\x -> factorize `mod` x == 0) . takeWhile (\x -> x*x < factorize)) generatePrimes
  in maximum primeFactors