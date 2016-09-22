{-# LANGUAGE OverloadedStrings #-}

module HelloWorld where

import           Network.Miku

import Network.HTTP.Pony.Serve (run)
import Network.HTTP.Pony.Serve.Wai (fromWAI)
import Network.HTTP.Pony.Transformer.HTTP (http)
import Network.HTTP.Pony.Transformer.CaseInsensitive (caseInsensitive)
import Network.HTTP.Pony.Transformer.StartLine (startLine)
import Pipes.Safe (runSafeT)

main :: IO ()
main =
  runSafeT
    . (run "localhost" "8080")
    . http
    . startLine
    . caseInsensitive
    . fromWAI
    . miku $
    get "/" (text "miku power")
