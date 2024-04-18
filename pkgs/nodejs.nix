{ fetchurl, stdenvNoCC, }:
let
  src = fetchurl
    ((builtins.fromJSON (builtins.readFile ../autogen.json)).nodejs);
in
stdenvNoCC.mkDerivation {
  name = "nodejs";
  inherit src;
  installPhase = ''
    runHook preInstall

    cp -R ./ $out

    runHook postInstall
  '';
  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/node --version
  '';
  strictDeps = true;
}
