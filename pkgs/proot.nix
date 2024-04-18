{ autoPatchelfHook, fetchurl, stdenvNoCC, }:
let
  src = fetchurl
    ((builtins.fromJSON (builtins.readFile ../autogen.json)).proot);
in
stdenvNoCC.mkDerivation {
  name = "proot";
  dontUnpack = true;
  nativeBuildInputs = [ autoPatchelfHook ];
  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -Dm755 ${src} $out/bin/proot

    runHook postInstall
  '';
  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/proot --version
  '';
  strictDeps = true;
}
