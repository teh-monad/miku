{-# LANGUAGE OverloadedStrings #-}

module Network.Miku.Utils where

import Control.Monad.State
import Hack2
import Prelude hiding ((-))
import qualified Data.ByteString.Char8 as B
import Data.ByteString.Char8 (ByteString)
import Control.Lens ((#), (&))
import Data.Bifunctor (first)
import Data.Monoid ((<>))

infixr 0 -
{-# INLINE (-) #-}
(-) :: (a -> b) -> a -> b
f - x = f x

namespace :: ByteString -> Env -> [(ByteString, ByteString)]
namespace x =
      map (first (B.drop (B.length x)))
    . filter ((x `B.isPrefixOf`) . fst)
    . hackHeaders

put_namespace :: ByteString -> [(ByteString, ByteString)] -> Env -> Env
put_namespace x xs env =
  let adds             = map (first (x <>)) xs
      new_headers      = map fst adds
      new_hack_headers =
        (hackHeaders env & filter (flip notElem new_headers . fst))
        <> adds

  in
  env {hackHeaders = new_hack_headers}



insert_last :: a -> [a] -> [a]
insert_last x xs = xs ++ [x]

update :: (MonadState a m, Functor m) => (a -> a) -> m ()
update = modify

