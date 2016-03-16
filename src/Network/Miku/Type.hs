{-# LANGUAGE TemplateHaskell #-}

module Network.Miku.Type where

import           Air.Data.Default
import           Air.Data.Record.SimpleLabel
import           Air.TH
import           Control.Lens
import           Control.Lens.TH
import           Control.Monad.Reader
import           Control.Monad.State
import           Data.ByteString.Char8       (ByteString)
import           Data.Monoid
import           Hack2
import           Hack2.Contrib.Utils
import Control.Monad.Identity

type AppReader    = Env
type AppState     = Response
type AppMonadT    = ReaderT AppReader (StateT AppState IO)
type AppMonad     = AppMonadT ()


data MikuState = MikuState
  {
    _middlewares :: [Middleware]
  , _router      :: [Middleware]
  , _mimes       :: [(ByteString, ByteString)]
  }

instance Monoid MikuState where
   mempty = MikuState [] [] []
   mappend (MikuState x y z) (MikuState x' y' z') = MikuState (x <> x') (y <> y') (z <> z')

makeLenses ''MikuState

type MikuMonadT a = State MikuState a
type MikuMonad    = MikuMonadT () -- (Identity ())
