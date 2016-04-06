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
            ]
    ]