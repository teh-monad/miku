{-# LANGUAGE OverloadedStrings #-}

module HTMLUsingMoe where

import qualified Network.Miku as Miku
import Network.Miku (get, miku)
import Network.Miku.Utils ((-))
import Hack2.Handler.SnapServer
import Text.HTML.Moe2

import Prelude hiding ((-), head, div, (/))
import qualified Data.ByteString.Lazy.Char8 as LB
import Control.Lens
import Data.ByteString.Lens


hello_page :: LB.ByteString
hello_page = render_bytestring -
  html - do
    head - do
      meta ! [http_equiv "Content-Type", content "text/html; charset=utf-8"] - (/)
      title - str "my title"

    body - do
      div ! [_class "container"] - do
        str "hello world"

main :: IO ()
main = do
  putStrLn - "server started..."

  run - miku - do
    get "/" - do
      Miku.html - view packedChars - review packedChars hello_page
