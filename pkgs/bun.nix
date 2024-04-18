{ autoPatchelfHook, fetchurl, stdenvNoCC, unzip }:
let
  src = fetchurl
    ((builtins.fromJSON (builtins.readFile ../autogen.json)).bun);
in
stdenvNoCC.mkDerivation {
  name = "bun";
  dontUnpack = true;
  nativeBuildInputs = [ autoPatchelfHook unzip ];
  installPhase = ''
    runHook preInstall

    unzip ${src}
    mkdir -p $out/bin
    install -Dm755 */bun $out/bin

    runHook postInstall
  '';
  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/bun --version
  '';
  strictDeps = true;
}
