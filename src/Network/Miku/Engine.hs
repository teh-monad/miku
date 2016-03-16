{-# LANGUAGE NamedFieldPuns    #-}
{-# LANGUAGE OverloadedStrings #-}


module Network.Miku.Engine where

import           Control.Lens          hiding (use)
import           Control.Monad.Reader  hiding (join)
import           Control.Monad.State   hiding (join)
import           Data.Bifunctor        (first)
import           Data.ByteString.Char8 (ByteString)
import qualified Data.ByteString.Char8 as B
import           Data.CaseInsensitive  (CI)
import qualified Data.CaseInsensitive  as CI
import qualified Data.Default          as Default
import           Data.List
import           Data.Maybe
import qualified Network.HTTP.Types    as H
import           Network.Miku.Config
import           Network.Miku.Type
import           Network.Miku.Utils
import           Network.Wai
import           Prelude               hiding ((-))
import           System.FilePath       ((</>))

emptyResponse :: Response
emptyResponse = responseLBS H.status200
                   [("Content-Type", "text/plain")]
                   "empty app"

emptyApp :: Application
emptyApp _ respond = respond - emptyResponse

miku :: MikuMonad -> Application
miku = flip miku_middleware emptyApp

use :: [Middleware] -> Middleware
use = foldl (.) id

miku_middleware :: MikuMonad -> Middleware
miku_middleware miku_monad =

  let miku_state                      = execState miku_monad mempty
      mime_filter                     = id -- user_mime - miku_state ^. mimes
      miku_middleware_stack           = use - miku_state ^. middlewares
      miku_router_middleware          = use - miku_state ^. router
      pre_installed_middleware_stack  = use - pre_installed_middlewares
  in

  use [pre_installed_middleware_stack, mime_filter, miku_middleware_stack, miku_router_middleware]


miku_router :: H.Method -> ByteString -> AppMonad -> Middleware
miku_router route_method route_string app_monad app = \env ->
  if requestMethod env == route_method
    then
      case env & rawPathInfo & parse_params route_string of
        Nothing -> app env
        Just (_, params) ->
          let mikuHeaders = params & map (first CI.mk)
              miku_app = run_app_monad - local (putNamespace miku_captures mikuHeaders) app_monad
          in
          miku_app env

    else
      app env


  where


    run_app_monad :: AppMonad -> Application
    run_app_monad app_monad env respond = do
      r <- runReaderT app_monad env & flip execStateT emptyResponse
      respond r


parse_params :: ByteString -> ByteString -> Maybe (ByteString, [(ByteString, ByteString)])
parse_params "*" x = Just (x, [])
parse_params "" ""  = Just ("", [])
parse_params "" _   = Nothing
parse_params "/" "" = Nothing
parse_params "/" "/"  = Just ("/", [])

parse_params t s =

  let template_tokens = B.split '/' t
      url_tokens      = B.split '/' s

      _template_last_token_matches_everything         = (template_tokens & length) > 0 && (["*"] `isSuffixOf` template_tokens)
      _template_tokens_length_equals_url_token_length = (template_tokens & length) == (url_tokens & length)
  in

  if not - _template_last_token_matches_everything || _template_tokens_length_equals_url_token_length
    then Nothing
    else
      let rs = zipWith capture template_tokens url_tokens
      in
      if all isJust rs
        then
          let token_length = length template_tokens
              location     = B.pack - "/" </> (B.unpack - B.intercalate "/" - take token_length url_tokens)
          in
          Just - (location, rs & catMaybes & catMaybes)
        else Nothing

  where
    capture x y
      | ":" `isPrefixOf` B.unpack x = Just - Just (B.tail x, y)
      | x == "*" = Just Nothing
      | x == y = Just Nothing
      | otherwise = Nothing
