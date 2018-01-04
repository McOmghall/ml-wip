-- Maths and language
module Wittgenstein where

import Control.Applicative
import Control.Monad
import Data.Char
import Data.List
import System.IO


num2wstr :: Integer -> Maybe [String]
num2wstr 0         = Just []
num2wstr n | n < 0 = (:) <$> Just "minus" <*> (num2wstr $ abs n)

num2wstr n | n < 100 = let
    concat  = (++) <$> tens <*> ("" : map ('-' :) simple)
    simple  = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]
    simplex = ["ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen"]
    tens    = ["twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety"]
  in Just [(simple ++ simplex ++ concat) !! (fromIntegral $ n - 1)]

num2wstr n = foldM dot [] $ transpose [numbers, tail numbers]
  where
    dot' n xn xs = (\x y -> x ++ [xs] ++ y)
      <$> num2wstr (n `div` xn)
      <*> num2wstr (n `mod` xn)
    
    dot a@(_:_) _ = Just a
    dot a ([(xn,xs),(yn,_)])
      | n < xn * yn `div` xn = dot' n xn xs
      | otherwise            = Just a
    dot a ([(xn,xs)])
      | n < xn * xn          = dot' n xn xs
      | otherwise            = Nothing
    
    numbers = [
      (10 ^    2, "hundred"),
      (10 ^    3, "thousand"),
      (10 ^    6, "million"),
      (10 ^    9, "billion"),
      (10 ^   12, "trillion"),
      (10 ^   15, "quadrillion"),
      (10 ^   18, "quintillion"),
      (10 ^   21, "sextillion"),
      (10 ^   24, "septillion"),
      (10 ^   27, "octillion"),
      (10 ^   30, "nonillion"),
      (10 ^   33, "decillion"),
      (10 ^   36, "undecillion"),
      (10 ^   39, "duodecillion"),
      (10 ^   42, "tredecillion"),
      (10 ^   45, "quattuordecillion"),
      (10 ^   48, "quindecillion"),
      (10 ^   51, "sexdecillion"),
      (10 ^   54, "septendecillion"),
      (10 ^   57, "octodecillion"),
      (10 ^   60, "novemdecillion"),
      (10 ^   63, "vigintillion"),
      (10 ^   66, "unvigintillion"),
      (10 ^   69, "duovigintillion"),
      (10 ^   72, "tresvigintillion"),
      (10 ^   75, "quattuorvigintillion"),
      (10 ^   78, "quinquavigintillion"),
      (10 ^   81, "sesvigintillion"),
      (10 ^   84, "septemvigintillion"),
      (10 ^   87, "octovigintillion"),
      (10 ^   90, "novemvigintillion"),
      (10 ^   93, "trigintillion"),
      (10 ^   96, "untrigintillion"),
      (10 ^   99, "duotrigintillion"),
      (10 ^  102, "trestrigintillion"),
      (10 ^  105, "quattuortrigintillion"),
      (10 ^  108, "quinquatrigintillion"),
      (10 ^  111, "sestrigintillion"),
      (10 ^  114, "septentrigitillion"),
      (10 ^  117, "octotrigintillion"),
      (10 ^  120, "noventrigintillion"),
      (10 ^  123, "quadragintillion"),
      (10 ^  153, "quinquagintillion"),
      (10 ^  183, "sexagintillion"),
      (10 ^  213, "septuagintillion"),
      (10 ^  243, "octogintillion"),
      (10 ^  273, "nonagintillion"),
      (10 ^  303, "centillion"),
      (10 ^  306, "uncentillion"),
      (10 ^  309, "duocentillion"),
      (10 ^  312, "trescentillion"),
      (10 ^  333, "decicentillion"),
      (10 ^  336, "undecicentillion"),
      (10 ^  363, "viginticentillion"),
      (10 ^  366, "unviginticentillion"),
      (10 ^  393, "trigintacentillion"),
      (10 ^  423, "quadragintacentillion"),
      (10 ^  453, "quinquagintacentillion"),
      (10 ^  483, "sexagintacentillion"),
      (10 ^  513, "septuagintacentillion"),
      (10 ^  543, "octogintacentillion"),
      (10 ^  573, "nonagintacentillion"),
      (10 ^  603, "ducentillion"),
      (10 ^  903, "trecentillion"),
      (10 ^ 1203, "quadringentillion"),
      (10 ^ 1503, "quingentillion"),
      (10 ^ 1803, "sescentillion"),
      (10 ^ 2103, "septingentillion"),
      (10 ^ 2403, "octingentillion"),
      (10 ^ 2703, "nongentillion")]

num2wstr' :: Integer -> String
num2wstr' 0 = "Zero."
num2wstr' x =
  case num2wstr x of
    Just xs -> toUpper' . (++ ".") . intercalate " " $ xs
    Nothing -> "Number too large."
  where
    toUpper' (x:xs) = toUpper x : xs
