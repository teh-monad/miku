{-# LANGUAGE OverloadedStrings #-}

module Network.Miku.DSL where

import           Blaze.ByteString.Builder            (fromByteString)
import           Control.Monad.Reader
import           Control.Monad.State
import           Data.ByteString.Char8               (ByteString)
import qualified Data.CaseInsensitive                as CI
import qualified Network.HTTP.Types                  as H
import           Network.Miku.Config
import           Network.Miku.Engine
import           Network.Miku.Type
import           Network.Miku.Utils
import           Network.Wai
import           Network.Wai.Middleware.StripHeaders
import           Prelude                             hiding ((-))

middleware :: Middleware -> MikuMonad
middleware x = do
  modify - \_state -> _state { middlewares = insertLast x - middlewares _state }

get, put, post, delete :: ByteString -> AppMonad -> MikuMonad
get    = addRoute H.methodGet
put    = addRoute H.methodPut
post   = addRoute H.methodPost
delete = addRoute H.methodDelete


addRoute :: H.Method -> ByteString -> AppMonad -> MikuMonad
addRoute routeMethod routeString appMonad = do
  let newRoute = mikuRouter routeMethod routeString appMonad

  modify - \_state -> _state { router = insertLast newRoute - router _state }


_ContentType :: ByteString
_ContentType = "Content-Type"

setContentType :: ByteString -> Response -> Response
setContentType x = mapResponseHeaders ((CI.mk _ContentType, x):) . stripHeader _ContentType

setBody :: ByteString -> Response -> Response
setBody x r = responseBuilder (responseStatus r) (responseHeaders r) - fromByteString x

text :: ByteString -> AppMonad
text x = do
  modify - setContentType "text/plain; charset=UTF-8"
  modify - setBody - x

html :: ByteString -> AppMonad
html x = do
  modify - setContentType "text/html; charset=UTF-8"
  modify - setBody - x


json :: ByteString -> AppMonad
json x = do
  modify - setContentType "text/json"
  modify - setBody - x

captures :: AppMonadT [(ByteString, ByteString)]
captures = namespace mikuCaptures <$> ask
