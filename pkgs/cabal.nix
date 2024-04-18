{ fetchurl, stdenvNoCC }:
let
  src = fetchurl
    ((builtins.fromJSON (builtins.readFile ../autogen.json)).cabal);
in
stdenvNoCC.mkDerivation {
  name = "cabal";
  dontUnpack = true;
  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    tar xJf ${src} -C $out/bin cabal

    runHook postInstall
  '';
  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/cabal --version
  '';
  allowedReferences = [ ];
}
