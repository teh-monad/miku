{-# LANGUAGE OverloadedStrings #-}

module Network.Miku.DSL where

import           Blaze.ByteString.Builder            (fromByteString)
import           Control.Lens
import           Control.Monad.Reader
import           Control.Monad.State
import qualified Control.Monad.State                 as State
import           Data.ByteString.Char8               (ByteString)
import           Data.CaseInsensitive                (CI)
import qualified Data.CaseInsensitive                as CI
import qualified Network.HTTP.Types                  as H
import           Network.Miku.Config
import           Network.Miku.Engine
import           Network.Miku.Type
import           Network.Miku.Utils
import           Network.Wai
import           Network.Wai.Middleware.StripHeaders
import           Prelude                             hiding ((-))

-- import Network.Wai.Middleware.Static

-- app :: Application -> AppMonad
-- app f = ask >>= (liftIO . f) >>= State.put

middleware :: Middleware -> MikuMonad
middleware x = middlewares %= insertLast x

get, put, post, delete :: ByteString -> AppMonad -> MikuMonad
get    = add_route H.methodGet
put    = add_route H.methodPut
post   = add_route H.methodPost
delete = add_route H.methodDelete


add_route :: H.Method -> ByteString -> AppMonad -> MikuMonad
add_route route_method route_string app_monad = do
  modifying router - insertLast - miku_router route_method route_string app_monad

-- before :: (Env -> IO Env) -> MikuMonad
-- before = middleware . ioconfig

-- after :: (Response -> IO Response) -> MikuMonad
-- after = middleware . censor

-- mime :: ByteString -> ByteString -> MikuMonad
-- mime k v = mimes %= insertLast (CI.mk k,v)

-- public :: ByteString -> MikuMonad
-- public = staticPolicy . addBase . review (utf8 . _Text)

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

captures :: AppMonadT [H.Header]
captures = ask <&> namespace miku_captures
