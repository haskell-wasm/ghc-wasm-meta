{
  callPackage,
  coreutils,
  fetchurl,
  flavour,
  hostPlatform,
  lib,
  makeWrapper,
  runtimeShell,
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
  nodejs = callPackage ./nodejs.nix { };
in
stdenvNoCC.mkDerivation {
  name = "wasm32-wasi-ghc-${flavour}";

  inherit src;

  nativeBuildInputs = [
    makeWrapper
    wasi-sdk
    zstd
  ];
  buildInputs = [ runtimeShellPackage ];

  preConfigure = ''
    substituteInPlace lib/*.mjs \
      --replace "/usr/bin/env" "${coreutils}/bin/env"

    patchShebangs .

    configureFlags="$configureFlags --build=$system --host=$system $CONFIGURE_ARGS"
  '';

  configurePlatforms = [ ];

  postInstall = ''
    wrapProgram $out/lib/wasm32-wasi-ghc-9.*/bin/wasm32-wasi-ghc-9.* \
      --prefix PATH : ${lib.makeBinPath [ nodejs ]}
  '';

  dontBuild = true;
  dontFixup = true;
  strictDeps = true;
}
