{ mkDerivation, base, bytestring, containers
, mtl, stdenv

, moe
, wai
, wai-extra
, http-types
, lens

, nemesis
, pretty-show
, stylish-haskell
, happy
, hasktags
, foreign-store
, cabal-install

, pkgs

}:

let

  http-pony = import ../http-pony/default.nix {};
  http-pony-serve-wai = import ../http-pony-serve-wai/default.nix {};

in

mkDerivation {
  pname = "miku";
  version = "2016.3.17";
  src = ./.;
  libraryHaskellDepends = [

    base bytestring containers
    mtl

    moe
    wai
    wai-extra
    http-types

    lens

    pretty-show

  ];

  executableHaskellDepends = [
    http-pony
    http-pony-serve-wai

    cabal-install
    nemesis
    foreign-store

    stylish-haskell
    happy
    hasktags
  ];

  homepage = "https://github.com/nfjinjing/miku";
  description = "A minimum web dev DSL in Haskell";
  license = stdenv.lib.licenses.bsd3;
}
