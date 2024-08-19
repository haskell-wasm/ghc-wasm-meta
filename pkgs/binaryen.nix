{
  autoPatchelfHook,
  fetchurl,
  fixDarwinDylibNames,
  hostPlatform,
  lib,
  stdenv,
}:
let
  src = fetchurl ((builtins.fromJSON (builtins.readFile ../autogen.json))."${key}");
  key =
    {
      x86_64-linux = "binaryen";
      aarch64-linux = "binaryen_aarch64_linux";
      aarch64-darwin = "binaryen_aarch64_darwin";
      x86_64-darwin = "binaryen_x86_64_darwin";
    }
    ."${hostPlatform.system}";
in
stdenv.mkDerivation {
  name = "binaryen";
  inherit src;
  nativeBuildInputs =
    lib.optionals hostPlatform.isLinux [ autoPatchelfHook ]
    ++ lib.optionals hostPlatform.isDarwin [ fixDarwinDylibNames ];
  installPhase = ''
    runHook preInstall

    cp -R ./ $out

    runHook postInstall
  '';
  doInstallCheck = true;
  installCheckPhase = ''
    MIMALLOC_VERBOSE=1 $out/bin/wasm-opt --version
  '';
  strictDeps = true;
}
