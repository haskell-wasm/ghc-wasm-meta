{ callPackage
, coreutils
, fetchurl
, flavour
, hostPlatform
, lib
, makeWrapper
, nodejs_latest
, runtimeShell
, runtimeShellPackage
, stdenvNoCC
,
}:
let
  common-src = builtins.fromJSON (builtins.readFile ../autogen.json);
  src = fetchurl common-src."${key}";
  key =
    {
      x86_64-linux-gmp = "wasm32-wasi-ghc-gmp";
      "x86_64-linux-native" = "wasm32-wasi-ghc-native";
      "x86_64-linux-unreg" = "wasm32-wasi-ghc-unreg";
      "x86_64-linux-9.6" = "wasm32-wasi-ghc-9.6";
      "x86_64-linux-9.8" = "wasm32-wasi-ghc-9.8";
      "x86_64-linux-9.10" = "wasm32-wasi-ghc-9.10";
      "x86_64-linux-9.12" = "wasm32-wasi-ghc-9.12";
      "aarch64-darwin-9.10" = "wasm32-wasi-ghc-gmp-aarch64-darwin-9.10";
      "aarch64-darwin-9.12" = "wasm32-wasi-ghc-gmp-aarch64-darwin-9.12";
      "aarch64-linux-9.10" = "wasm32-wasi-ghc-gmp-aarch64-linux-9.10";
      "aarch64-linux-9.12" = "wasm32-wasi-ghc-gmp-aarch64-linux-9.12";
    }."${hostPlatform.system}-${flavour}";
  wasi-sdk = callPackage ./wasi-sdk.nix { };
  nodejs = nodejs_latest;
  npm-deps = callPackage ./npm-deps.nix { inherit nodejs; };
in
stdenvNoCC.mkDerivation {
  name = "wasm32-wasi-ghc-${flavour}";

  inherit src;

  nativeBuildInputs = [
    makeWrapper
    wasi-sdk
  ];
  buildInputs = [ runtimeShellPackage ];

  preConfigure =
    lib.optionalString
      (lib.elem flavour [
        "gmp"
        "native"
        "unreg"
        "9.10"
        "9.12"
      ])
      ''
        substituteInPlace lib/*.mjs \
          --replace "/usr/bin/env" "${coreutils}/bin/env"
      ''
    + ''
      patchShebangs .

      configureFlags="$configureFlags --build=$system --host=$system $CONFIGURE_ARGS"
    '';

  configurePlatforms = [ ];

  enableParallelInstalling = true;

  postInstall = ''
    wrapProgram $out/lib/wasm32-wasi-ghc-9.*/bin/wasm32-wasi-ghc-9.* \
      --prefix PATH : ${lib.makeBinPath [ nodejs ]} \
      --set-default NODE_PATH ${npm-deps}
  '';

  dontBuild = true;
  dontFixup = true;
  strictDeps = true;
}
