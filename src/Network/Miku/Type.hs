{-# LANGUAGE TemplateHaskell #-}

module Network.Miku.Type where

-- import           Control.Lens
import           Control.Monad.Identity
import           Control.Monad.Reader
import           Control.Monad.State
import           Data.Monoid
import           Network.Wai

type AppReader    = Request
type AppState     = Response
type AppMonadT    = ReaderT AppReader (StateT AppState IO)
type AppMonad     = AppMonadT ()


data MikuState = MikuState
  {
    middlewares :: [Middleware]
  , router      :: [Middleware]
  }

instance Monoid MikuState where
   mempty = MikuState [] []
   mappend (MikuState x y) (MikuState x' y') = MikuState (x <> x') (y <> y')

type MikuMonad = StateT MikuState Identity ()
