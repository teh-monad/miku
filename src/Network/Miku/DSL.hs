{-# LANGUAGE OverloadedStrings #-}

module Network.Miku.DSL where

import           Control.Lens
import           Control.Monad.Reader
import           Control.Monad.State
import qualified Control.Monad.State               as State
import           Data.ByteString.Char8             (ByteString)
import           Hack2
import           Hack2.Contrib.Constants
import           Hack2.Contrib.Middleware.Censor
import           Hack2.Contrib.Middleware.Config
import           Hack2.Contrib.Middleware.IOConfig
import           Hack2.Contrib.Middleware.Static
import           Hack2.Contrib.Response
import           Network.Miku.Config
import           Network.Miku.Engine
import           Network.Miku.Type
import           Network.Miku.Utils
import           Prelude                           hiding ((-))

app :: Application -> AppMonad
app f = ask >>= (liftIO . f) >>= State.put

middleware :: Middleware -> MikuMonad
middleware x = middlewares %= insert_last x

get, put, post, delete :: ByteString -> AppMonad -> MikuMonad
get    = add_route GET
put    = add_route PUT
post   = add_route POST
delete = add_route DELETE


add_route :: RequestMethod -> ByteString -> AppMonad -> MikuMonad
add_route route_method route_string app_monad = do
  modifying router - insert_last - miku_router route_method route_string app_monad

before :: (Env -> IO Env) -> MikuMonad
before = middleware . ioconfig

after :: (Response -> IO Response) -> MikuMonad
after = middleware . censor

mime :: ByteString -> ByteString -> MikuMonad
mime k v = mimes %= insert_last (k,v)

public :: Maybe ByteString -> [ByteString] -> MikuMonad
public r xs = middleware - static r xs

text :: ByteString -> AppMonad
text x = do
  update - set_content_type _TextPlain
  update - set_body_bytestring - x

html :: ByteString -> AppMonad
html x = do
  update - set_content_type _TextHtml
  update - set_body_bytestring - x


json :: ByteString -> AppMonad
json x = do
  update - set_content_type "text/json"
  update - set_body_bytestring - x

captures :: AppMonadT [(ByteString, ByteString)]
captures = ask <&> namespace miku_captures
