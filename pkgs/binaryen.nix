{ fetchurl, stdenvNoCC }:
let
  src = fetchurl
    ((builtins.fromJSON (builtins.readFile ../autogen.json)).binaryen);
in
stdenvNoCC.mkDerivation {
  name = "binaryen";
  inherit src;
  installPhase = ''
    runHook preInstall

    cp -R ./ $out

    runHook postInstall
  '';
  doInstallCheck = true;
  installCheckPhase = ''
    MIMALLOC_VERBOSE=1 $out/bin/wasm-opt --version
  '';
  allowedReferences = [ ];
}
