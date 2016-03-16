{-# LANGUAGE OverloadedStrings #-}

module Network.Miku.Utils where

import           Control.Lens          (( # ), (&))
import           Control.Monad.State
import           Data.Bifunctor        (first)
import           Data.ByteString.Char8 (ByteString)
import qualified Data.ByteString.Char8 as B
import           Data.CaseInsensitive  (CI)
import qualified Data.CaseInsensitive  as CI
import           Data.Monoid           ((<>))
import           Data.String
import qualified Network.HTTP.Types    as H
import           Network.Wai
import           Prelude               hiding ((-))

infixr 0 -
{-# INLINE (-) #-}
(-) :: (a -> b) -> a -> b
f - x = f x

namespace :: ByteString -> Request -> [H.Header]
namespace x =
      map (first . CI.map . B.drop - B.length x)
    . filter ((x `B.isPrefixOf`) . CI.original. fst)
    . requestHeaders

putNamespace :: ByteString -> [H.Header] -> Request -> Request
putNamespace x xs env =
  let adds             = map (first (CI.map (x <>))) xs
      newHeaders      = map fst adds
      newRequestHeaders =
        (requestHeaders env & filter (flip notElem newHeaders . fst))
        <> adds

  in
  env {requestHeaders = newRequestHeaders}



insertLast :: a -> [a] -> [a]
insertLast x xs = xs <> [x]


