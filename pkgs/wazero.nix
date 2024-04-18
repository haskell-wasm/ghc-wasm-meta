{ fetchurl, stdenvNoCC }:
let
  src = fetchurl
    ((builtins.fromJSON (builtins.readFile ../autogen.json)).wazero);
in
stdenvNoCC.mkDerivation {
  name = "wazero";
  dontUnpack = true;
  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    tar xzf ${src} -C $out/bin wazero

    runHook postInstall
  '';
  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/wazero -h
  '';
  allowedReferences = [ ];
}
