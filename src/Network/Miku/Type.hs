{-# LANGUAGE TemplateHaskell #-}

module Network.Miku.Type where

import           Control.Lens
import           Control.Lens.TH
import           Control.Monad.Identity
import           Control.Monad.Reader
import           Control.Monad.State
import           Data.ByteString.Char8       (ByteString)
import           Data.Monoid
import           Network.Wai
import qualified Network.HTTP.Types           as H

type AppReader    = Request
type AppState     = Response
type AppMonadT    = ReaderT AppReader (StateT AppState IO)
type AppMonad     = AppMonadT ()


data MikuState = MikuState
  {
    _middlewares :: [Middleware]
  , _router      :: [Middleware]
  , _mimes       :: [H.Header]
  }

instance Monoid MikuState where
   mempty = MikuState [] [] []
   mappend (MikuState x y z) (MikuState x' y' z') = MikuState (x <> x') (y <> y') (z <> z')

makeLenses ''MikuState

type MikuMonadT a = State MikuState a
type MikuMonad    = MikuMonadT () -- (Identity ())
