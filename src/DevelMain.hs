{-# LANGUAGE OverloadedStrings #-}

module DevelMain where

import Network.Miku
import Hack2.Handler.SnapServer
import Air.Env (fork)
import Foreign.Store

appMain :: IO ()
appMain = run . miku $ get "/" (text "miku power")

main :: IO ()
main = do
  fork appMain
  _ <- newStore ()
  return ()

-- | Update the server, start it if not running.
update :: IO ()
update =
  do m <- lookupStore 0
     case m of
       Nothing -> main
       Just _ -> pure ()
