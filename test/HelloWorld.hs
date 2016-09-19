{-# LANGUAGE OverloadedStrings #-}

module HelloWorld where

import           Network.Miku

import Network.HTTP.Pony.Serve (run)
import Network.HTTP.Pony.Serve.Wai (fromWAI)
import Pipes.Safe (runSafeT)

main :: IO ()
main =
  runSafeT . (run "localhost" "8080") . fromWAI . miku $
    get "/" (text "miku power")
