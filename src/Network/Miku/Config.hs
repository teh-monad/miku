{-# LANGUAGE OverloadedStrings #-}


module Network.Miku.Config where

import           Data.ByteString.Char8                  (ByteString)
import           Network.Miku.Utils
import           Network.Wai


pre_installed_middlewares :: [Middleware]
pre_installed_middlewares =
  [
  --   content_length
  -- , content_type default_content_type
  ]
  where
    default_content_type = "text/plain; charset=UTF-8"


miku_captures :: ByteString
miku_captures = "miku-captures-"
