{ autoPatchelfHook, fetchurl, stdenv, stdenvNoCC, unzip }:
let
  src = fetchurl
    ((builtins.fromJSON (builtins.readFile ../autogen.json)).deno);
in
stdenvNoCC.mkDerivation {
  name = "deno";
  dontUnpack = true;
  buildInputs = [ stdenv.cc.cc.lib ];
  nativeBuildInputs = [ autoPatchelfHook unzip ];
  installPhase = ''
    runHook preInstall

    unzip ${src}
    mkdir -p $out/bin
    install -Dm755 deno $out/bin

    runHook postInstall
  '';
  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/deno --version
  '';
  strictDeps = true;
}
