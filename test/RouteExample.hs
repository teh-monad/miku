{-# LANGUAGE OverloadedStrings #-}

module RouteExample where

import           Control.Monad.Reader
import qualified Data.ByteString.Char8                as B
import           Network.Miku
import           Network.Miku.Utils                   ((-))
import           Network.Wai.Middleware.RequestLogger
import           Prelude                              hiding ((-))

import Network.HTTP.Pony.Serve.Wai (fromWAI)
import Network.HTTP.Pony.Serve (run)
import Network.HTTP.Pony.Transformer.HTTP (http)
import Network.HTTP.Pony.Transformer.CaseInsensitive (caseInsensitive)
import Pipes.Safe (runSafeT)

appMain :: IO ()
appMain = do
  let io = liftIO

  putStrLn "server started on port 8080..."

  runSafeT . run "localhost" "8080"
           . http
           . caseInsensitive
           . fromWAI
           . miku - do

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
    -- mime "hs" "text/plain"
-- default on port 3000

main :: IO ()
main = appMain
