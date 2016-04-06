module Euler where

import Data.List (find)
-- Problems from https://projecteuler.net
-- https://projecteuler.net/problem=1
problem1 = 
  let mults3 = takeWhile (<1000) (map (*3) [1..])
      mults5 = filter (\x -> not (elem x mults3)) (takeWhile (<1000) (map (*5) [1..]))
  in sum (concat [mults3, mults5])

-- https://projecteuler.net/problem=2
problem2 = 
  let fibs = takeWhile (<4000000) (0 : 1 : zipWith (+) fibs (tail fibs))
  in sum (filter (even) fibs)

generatePrimes :: [Int]
generatePrimes = 2 : primes'
  where isPrime (p:ps) n = p*p > n || n `rem` p /= 0 && isPrime ps n
        primes' = 3 : filter (isPrime primes') [5, 7 ..]

-- https://projecteuler.net/problem=3
problem3solver :: Int -> Int
problem3solver factorize =
  let primeFactors = (filter (\x -> factorize `mod` x == 0) . takeWhile (\x -> x*x < factorize)) generatePrimes
  in maximum primeFactors

problem3 = problem3solver 600851475143

-- https://projecteuler.net/problem=4
problem4 = 
  let threeDigitNumbers = [100..999]
      combinatorial = [x * y | x <- threeDigitNumbers, y <- threeDigitNumbers]
      isPalindrome x = (show x) == ((reverse . show) x)
  in maximum . filter isPalindrome $ combinatorial

-- https://projecteuler.net/problem=5
problem5 = foldl lcm 1 [2..20]

problem6 = ((sum [1..100]) ^ 2) - (sum $ map (^2) [1..100]) 

