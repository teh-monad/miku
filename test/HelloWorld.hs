{-# LANGUAGE OverloadedStrings #-}

module HelloWorld where

import           Hack2.Handler.SnapServer
import           Network.Miku

main = run . miku $ get "/" (text "miku power")
