module Main where

import Euler

main :: IO ()
main = 
  do 
    putStrLn "Run test"
    print problem12        
    putStrLn "DONE: Press Enter"
    _ <- getLine
    return ()