{ stdenvNoCC, }:
let
  src = builtins.fetchTarball
    ((builtins.fromJSON (builtins.readFile ../autogen.json)).nodejs);
in
stdenvNoCC.mkDerivation {
  name = "nodejs";
  dontUnpack = true;
  installPhase = ''
    cp -a ${src} $out
    chmod -R u+w $out
  '';
  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/node --version
  '';
  strictDeps = true;
}
