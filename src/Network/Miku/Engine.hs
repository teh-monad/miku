{-# LANGUAGE NamedFieldPuns    #-}
{-# LANGUAGE OverloadedStrings #-}


module Network.Miku.Engine where

import           Control.Monad.Reader
import           Control.Monad.State
import           Data.Bifunctor        (first)
import           Data.ByteString.Char8 (ByteString)
import qualified Data.ByteString.Char8 as B
import qualified Data.CaseInsensitive  as CI
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
miku = flip mikuMiddleware emptyApp

use :: [Middleware] -> Middleware
use = foldl (.) id

mikuMiddleware :: MikuMonad -> Middleware
mikuMiddleware mikuMonad =

  let mikuState                      = execState mikuMonad mempty
      mikuMiddlewareStack           = use - middlewares mikuState
      mikuRouterMiddleware          = use - router mikuState
  in

  use [mikuMiddlewareStack, mikuRouterMiddleware]


mikuRouter :: H.Method -> ByteString -> AppMonad -> Middleware
mikuRouter routeMethod routeString appMonad app = \env ->
  if requestMethod env == routeMethod
    then
      case env & rawPathInfo & parseParams routeString of
        Nothing -> app env
        Just (_, params) ->
          let mikuHeaders = params & map (first CI.mk)
              mikuApp = _runAppMonad - local (putNamespace mikuCaptures mikuHeaders) appMonad
          in
          mikuApp env

    else
      app env


  where


    _runAppMonad :: AppMonad -> Application
    _runAppMonad _appMonad _env _respond = do
      r <- runReaderT _appMonad _env & flip execStateT emptyResponse
      _respond r


parseParams :: ByteString -> ByteString -> Maybe (ByteString, [(ByteString, ByteString)])
parseParams "*" x = Just (x, [])
parseParams "" ""  = Just ("", [])
parseParams "" _   = Nothing
parseParams "/" "" = Nothing
parseParams "/" "/"  = Just ("/", [])

parseParams t s =

  let templateTokens = B.split '/' t
      urlTokens      = B.split '/' s

      _templateLastTokenMatchesEverything         = (templateTokens & length) > 0 && (["*"] `isSuffixOf` templateTokens)
      _templateTokensLengthEqualsUrlTokenLength = (templateTokens & length) == (urlTokens & length)
  in

  if not - _templateLastTokenMatchesEverything || _templateTokensLengthEqualsUrlTokenLength
    then Nothing
    else
      let rs = zipWith capture templateTokens urlTokens
      in
      if all isJust rs
        then
          let tokenLength = length templateTokens
              location     = B.pack - "/" </> (B.unpack - B.intercalate "/" - take tokenLength urlTokens)
          in
          Just - (location, rs & catMaybes & catMaybes)
        else Nothing

  where
    capture x y
      | ":" `isPrefixOf` B.unpack x = Just - Just (B.tail x, y)
      | x == "*" = Just Nothing
      | x == y = Just Nothing
      | otherwise = Nothing
