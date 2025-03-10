import Test.HUnit
import Test.Framework
import Test.Framework.Providers.HUnit
import Data.Monoid
import Control.Monad
import qualified Euler as Euler

main :: IO ()
main = defaultMain tests

mainWithOpts = do
  let empty_test_opts = mempty :: TestOptions
  let my_test_opts = empty_test_opts {
    topt_maximum_generated_tests = Just 500
  }
  let empty_runner_opts = mempty :: RunnerOptions
  let my_runner_opts = empty_runner_opts {
    ropt_test_options = Just my_test_opts
  }
  defaultMainWithOpts tests my_runner_opts

tests = [
        testGroup "Euler Exercises" [
                testCase "Problem 1" (assertEqual "Not solved" Euler.problem1 233168)
               ,testCase "Problem 2" (assertEqual "Not solved" Euler.problem2 4613732)
               ,testCase "Problem 3" (assertEqual "Not solved" Euler.problem3 6857)
               ,testCase "Problem 4" (assertEqual "Not solved" Euler.problem4 906609)
               ,testCase "Problem 5" (assertEqual "Not solved" Euler.problem5 232792560)
               ,testCase "Problem 6" (assertEqual "Not solved" Euler.problem6 25164150)
               ,testCase "Problem 7" (assertEqual "Not solved" Euler.problem7 104743)
               ,testCase "Problem 8" (assertEqual "Not solved" Euler.problem8 23514624000)
               ,testCase "Problem 9" (assertEqual "Not solved" Euler.problem9 31875000)
               ,testCase "Problem 10" (assertEqual "Not solved" Euler.problem10 142913828922)
               ,testCase "Problem 11" (assertEqual "Not solved" Euler.problem11 70600674)
               ,testCase "Problem 12" (assertEqual "Not solved" Euler.problem12 76576500)
               ,testCase "Problem 13" (assertEqual "Not solved" Euler.problem13 5537376230)
               ,testCase "Problem 14" (assertEqual "Not solved" Euler.problem14 837799)
               ,testCase "Problem 15" (assertEqual "Not solved" Euler.problem15 137846528820)
               ,testCase "Problem 16" (assertEqual "Not solved" Euler.problem16 1366)
               ,testCase "Problem 17" (assertEqual "Not solved" Euler.problem17 18451)  -- Not really solved, Euler project doesn't specify a validation algorithm for the number strings, therefore it's impossible to know what the error is
            ]
    ]