{ autoPatchelfHook
, fetchurl
, fixDarwinDylibNames
, hostPlatform
, lib
, stdenv
, stdenvNoCC
,
}:
let
  src = fetchurl ((builtins.fromJSON (builtins.readFile ../autogen.json))."${key}");
  key =
    {
      x86_64-linux = "nodejs";
      aarch64-linux = "nodejs_aarch64_linux";
      aarch64-darwin = "nodejs_aarch64_darwin";
      x86_64-darwin = "nodejs_x86_64_darwin";
    }."${hostPlatform.system}";
in
stdenvNoCC.mkDerivation {
  name = "nodejs";
  inherit src;
  nativeBuildInputs =
    lib.optionals hostPlatform.isLinux [ autoPatchelfHook ]
    ++ lib.optionals hostPlatform.isDarwin [ fixDarwinDylibNames ];
  buildInputs = [ stdenv.cc.cc.lib ];
  installPhase = ''
    runHook preInstall

    cp -R ./ $out

    runHook postInstall
  '';
  doInstallCheck = true;
  installCheckPhase = ''
    MIMALLOC_VERBOSE=1 $out/bin/node --version
  '';
  strictDeps = true;
}
