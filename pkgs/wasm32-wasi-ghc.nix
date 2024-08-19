{
  callPackage,
  fetchurl,
  flavour,
  hostPlatform,
  runtimeShellPackage,
  stdenvNoCC,
  zstd,
}:
let
  common-src = builtins.fromJSON (builtins.readFile ../autogen.json);
  src = fetchurl (
    if hostPlatform.isx86_64 && hostPlatform.isLinux then
      common-src."wasm32-wasi-ghc-${flavour}"
    else
      common-src."${key}"
  );
  key =
    {
      aarch64-linux = "wasm32-wasi-ghc-gmp-aarch64-linux";
      aarch64-darwin = "wasm32-wasi-ghc-gmp-aarch64-darwin";
      x86_64-darwin = "wasm32-wasi-ghc-gmp-x86_64-darwin";
    }
    ."${hostPlatform.system}";
  wasi-sdk = callPackage ./wasi-sdk.nix { };
in
stdenvNoCC.mkDerivation {
  name = "wasm32-wasi-ghc-${flavour}";

  inherit src;

  nativeBuildInputs = [
    wasi-sdk
    zstd
  ];
  buildInputs = [ runtimeShellPackage ];

  preConfigure = ''
    patchShebangs .
    configureFlags="$configureFlags --build=$system --host=$system $CONFIGURE_ARGS"
  '';

  configurePlatforms = [ ];

  dontBuild = true;
  dontFixup = true;
  strictDeps = true;
}
