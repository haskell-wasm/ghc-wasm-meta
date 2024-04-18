{ autoPatchelfHook, fetchurl, openssl, stdenv, stdenvNoCC, }:
let
  src = fetchurl
    ((builtins.fromJSON (builtins.readFile ../autogen.json)).wabt);
in
stdenvNoCC.mkDerivation {
  name = "wabt";
  inherit src;
  buildInputs = [ openssl stdenv.cc.cc.lib ];
  nativeBuildInputs = [ autoPatchelfHook ];
  installPhase = ''
    runHook preInstall

    cp -R ./ $out

    runHook postInstall
  '';
  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/wasm-objdump --version
  '';
  strictDeps = true;
}
