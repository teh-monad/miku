{-# LANGUAGE OverloadedStrings #-}

module RouteExample where

import           Control.Concurrent                   (forkIO)
import           Control.Lens
import           Control.Monad.Reader
import qualified Data.ByteString.Char8                as B
import qualified Data.ByteString.Lazy.Char8           as Lazy
import           Data.Maybe
import           Data.Monoid
import           Network.Miku
import           Network.Miku.Utils                   ((-))
import           Network.Wai.Handler.Warp             (run)
import           Network.Wai.Middleware.RequestLogger
import           Prelude                              hiding ((-))

appMain :: IO ()
appMain = do
  let io = liftIO

  putStrLn "server started on port 3000..."

  run 3000 . miku - do

    -- before return
    -- after return

    middleware logStdout

    -- get "/bench" - do
    --   name <- ask <&> params <&> lookup "name" <&> fromMaybe "nobody"
    --   html ("<h1>" <> name <> "</h1>")

    -- simple
    get "/hello"    (text "hello world")

    get "/debug"    (text . B.pack . show =<< ask)

    -- io
    get "/cabal"    - text =<< io (B.readFile "miku.cabal")

    -- route captures
    get "/say/:user/:message" - do
      text . B.pack . show =<< captures

    -- html output
    get "/html"     (html "<html><body><p>miku power!</p></body></html>")


    get "/" - do
      text "match /"

    get "/test-star/*/hi" - do
      text "test-star/*/hi"

    -- default
    get "*" - do
      text "match everything"

    -- public serve, only allows /src
    -- public (Just ".") ["/src"]

    -- treat .hs extension as text/plain
    mime "hs" "text/plain"
-- default on port 3000

main :: IO ()
main = appMain
