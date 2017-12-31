module Euler where

  import Data.List (find)
  import Data.Char (digitToInt)
  import Data.Maybe (fromJust)

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

  -- https://projecteuler.net/problem=3
  generatePrimes :: [Int]
  generatePrimes = 2 : primes
    where isPrime (p:ps) n = p*p > n || n `rem` p /= 0 && isPrime ps n
          primes = 3 : filter (isPrime primes) [5, 7 ..]

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

  -- https://projecteuler.net/problem=6
  problem6 = ((sum [1..100]) ^ 2) - (sum $ map (^2) [1..100])

  -- https://projecteuler.net/problem=7
  problem7 = last $ take 10001 generatePrimes

  -- https://projecteuler.net/problem=8
  windows :: Int -> [a] -> [[a]]
  windows n [] = [[]]
  windows 0 a  = [[]]
  windows 1 a  = map (\e -> [e]) a
  windows n a  = (take n a) : (windows n (tail a))  

  problem8 =
    let number = "7316717653133062491922511967442657474235534919493496983520312774506326239578318016984801869478851843858615607891129494954595017379583319528532088055111254069874715852386305071569329096329522744304355766896648950445244523161731856403098711121722383113622298934233803081353362766142828064444866452387493035890729629049156044077239071381051585930796086670172427121883998797908792274921901699720888093776657273330010533678812202354218097512545405947522435258490771167055601360483958644670632441572215539753697817977846174064955149290862569321978468622482839722413756570560574902614079729686524145351004748216637048440319989000889524345065854122758866688116427171479924442928230863465674813919123162824586178664583591245665294765456828489128831426076900422421902267105562632111110937054421750694165896040807198403850962455444362981230987879927244284909188845801561660979191338754992005240636899125607176060588611646710940507754100225698315520005593572972571636269561882670428252483600823257530420752963450"
        numberArray = map digitToInt number
        windowOf13thProducts = map product (windows 13 numberArray)
    in maximum windowOf13thProducts

  -- https://projecteuler.net/problem=9
  problem9 = 
    let range   = [1..1000]
        top = maximum range
        lambdaTriples = \n -> [(n, y, z) | y <- filter (\e -> (e > n) && (e + n < top)) range, z <- filter (\e -> (e > y) && (e + n + y == top)) range, (n^2 + y^2 == z^2)]
        triple = find (\e -> length e > 0) . map lambdaTriples $ range
    in (\(x, y, z) -> x * y * z) . head . fromJust $ triple
 
  -- https://projecteuler.net/problem=10
  problem10 = sum $ takeWhile (< 2 * 10^6) generatePrimes
    