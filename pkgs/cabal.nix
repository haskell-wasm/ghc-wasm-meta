{ autoPatchelfHook
, fetchurl
, fixDarwinDylibNames
, gmp
, hostPlatform
, lib
, stdenvNoCC
,
}:
let
  src = fetchurl ((builtins.fromJSON (builtins.readFile ../autogen.json))."${key}");
  key =
    {
      x86_64-linux = "cabal";
      aarch64-linux = "cabal_aarch64_linux";
      aarch64-darwin = "cabal_aarch64_darwin";
      x86_64-darwin = "cabal_x86_64_darwin";
    }."${hostPlatform.system}";
in
stdenvNoCC.mkDerivation {
  name = "cabal";
  dontUnpack = true;
  nativeBuildInputs =
    lib.optionals hostPlatform.isLinux [ autoPatchelfHook ]
    ++ lib.optionals hostPlatform.isDarwin [ fixDarwinDylibNames ];
  buildInputs = [ gmp ];
  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    tar xJf ${src} -C $out/bin cabal

    runHook postInstall
  '';
  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/cabal --version
  '';
  strictDeps = true;
}
