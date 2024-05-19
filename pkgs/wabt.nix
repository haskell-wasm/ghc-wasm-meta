{ autoPatchelfHook, fetchurl, openssl_1_1, stdenv, stdenvNoCC, }:
let
  src = fetchurl
    ((builtins.fromJSON (builtins.readFile ../autogen.json)).wabt);
in
stdenvNoCC.mkDerivation {
  name = "wabt";
  inherit src;
  buildInputs = [ openssl_1_1 stdenv.cc.cc.lib ];
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
