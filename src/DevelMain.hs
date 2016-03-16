{-# LANGUAGE OverloadedStrings #-}

module DevelMain where

import           Control.Concurrent (forkIO)
import           Foreign.Store
import           Prelude            hiding ((-))
import qualified RouteExample       as RouteExample

main :: IO ()
main = do
  forkIO RouteExample.main
  -- forkIO HelloWorld.main
  -- forkIO HTMLUsingMoe.main
  _ <- newStore ()
  return ()

-- | Update the server, start it if not running.
update :: IO ()
update =
  do m <- lookupStore 0
     case m of
       Nothing -> main
       Just _ -> pure ()
