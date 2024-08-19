{ autoPatchelfHook
, fetchurl
, fixDarwinDylibNames
, hostPlatform
, lib
, stdenv
, stdenvNoCC
, unzip
,
}:
let
  src = fetchurl ((builtins.fromJSON (builtins.readFile ../autogen.json))."${key}");
  key =
    {
      x86_64-linux = "deno";
      aarch64-linux = "deno_aarch64_linux";
      aarch64-darwin = "deno_aarch64_darwin";
      x86_64-darwin = "deno_x86_64_darwin";
    }."${hostPlatform.system}";
in
stdenvNoCC.mkDerivation {
  name = "deno";
  dontUnpack = true;
  buildInputs = [ stdenv.cc.cc.lib ];
  nativeBuildInputs =
    lib.optionals hostPlatform.isLinux [ autoPatchelfHook ]
    ++ lib.optionals hostPlatform.isDarwin [ fixDarwinDylibNames ]
    ++ [ unzip ];
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
