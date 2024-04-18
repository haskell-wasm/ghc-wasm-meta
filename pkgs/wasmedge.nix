{ autoPatchelfHook, fetchurl, ncurses, stdenv, stdenvNoCC, zlib, }:
let
  src = fetchurl
    ((builtins.fromJSON (builtins.readFile ../autogen.json)).wasmedge);
in
stdenvNoCC.mkDerivation {
  name = "wasmedge";
  inherit src;
  buildInputs = [ ncurses stdenv.cc.cc.lib zlib ];
  nativeBuildInputs = [ autoPatchelfHook ];
  installPhase = ''
    runHook preInstall

    cp -R ./ $out

    runHook postInstall
  '';
  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/wasmedge --version
  '';
  strictDeps = true;
}
