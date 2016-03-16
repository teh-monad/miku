{-# LANGUAGE OverloadedStrings #-}

module HTMLUsingMoe where

import           Control.Lens
import qualified Data.ByteString.Lazy.Char8 as LB
import           Data.ByteString.Lens
import           Network.Miku               (get, miku)
import qualified Network.Miku               as Miku
import           Network.Miku.Utils         ((-))
import           Network.Wai.Handler.Warp   (run)
import           Prelude                    hiding (div, head, (-), (/))
import           Text.HTML.Moe2

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

  run 3000 - miku - do
    get "/" - do
      Miku.html - view packedChars - review packedChars hello_page
