{-# LANGUAGE OverloadedStrings #-}

module Network.Miku.Utils where

import           Data.Bifunctor        (first)
import           Data.ByteString.Char8 (ByteString)
import qualified Data.ByteString.Char8 as B
import qualified Data.CaseInsensitive  as CI
import           Data.Monoid           ((<>))
import qualified Network.HTTP.Types    as H
import           Network.Wai
import           Prelude               hiding ((-))

infixr 0 -
{-# INLINE (-) #-}
(-) :: (a -> b) -> a -> b
f - x = f x

infixl 1 &
{-# INLINE (&) #-}
(&) :: a -> (a -> b) -> b
x & f = f x

namespace :: ByteString -> Request -> [(ByteString, ByteString)]
namespace x =
      map (first (B.drop - B.length x))
    . filter ((x `B.isPrefixOf`) . fst)
    . map (first CI.original)
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


