{ autoPatchelfHook
, fetchurl
, fixDarwinDylibNames
, hostPlatform
, lib
, stdenvNoCC
, unzip
,
}:
let
  src = fetchurl ((builtins.fromJSON (builtins.readFile ../autogen.json))."${key}");
  key =
    {
      x86_64-linux = "bun";
      aarch64-linux = "bun_aarch64_linux";
      aarch64-darwin = "bun_aarch64_darwin";
      x86_64-darwin = "bun_x86_64_darwin";
    }."${hostPlatform.system}";
in
stdenvNoCC.mkDerivation {
  name = "bun";
  dontUnpack = true;
  nativeBuildInputs =
    lib.optionals hostPlatform.isLinux [ autoPatchelfHook ]
    ++ lib.optionals hostPlatform.isDarwin [ fixDarwinDylibNames ]
    ++ [ unzip ];
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
