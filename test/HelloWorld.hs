{-# LANGUAGE OverloadedStrings #-}

module HelloWorld where

import           Network.Miku
import           Network.Wai.Handler.Warp (run)

main :: IO ()
main = run 3000 . miku $ get "/" (text "miku power")
