{ mkDerivation, air, air-th, base, bytestring, containers
, data-default, hack2, hack2-contrib, mtl, stdenv

, nemesis
, pretty-show
, stylish-haskell
, happy
, hasktags
, foreign-store
, lens

, hack2-handler-snap-server
, snap-server

, pkgs

}:
mkDerivation {
  pname = "miku";
  version = "2014.11.17";
  src = ./.;
  libraryHaskellDepends = [
    air air-th base bytestring containers data-default hack2
    hack2-contrib mtl

    happy
    stylish-haskell
    happy

    nemesis
    pretty-show
    foreign-store
    lens

    hack2-handler-snap-server
    snap-server
  ] ++
  (with pkgs;
    [
      entr
    ]
  );

  homepage = "https://github.com/nfjinjing/miku";
  description = "A minimum web dev DSL in Haskell";
  license = stdenv.lib.licenses.bsd3;
}
