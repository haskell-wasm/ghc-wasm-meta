{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachSystem
      [
        "x86_64-linux"
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
      ]
      (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config = {
              permittedInsecurePackages = [ "openssl-1.1.1w" ];
            };
          };
          all =
            flavour:
            pkgs.symlinkJoin {
              name = "ghc-wasm";
              paths =
                [
                  pkgs.haskellPackages.alex
                  pkgs.haskellPackages.happy
                  (pkgs.callPackage ./pkgs/wasm32-wasi-ghc.nix { inherit flavour; })
                  wasi-sdk
                  pkgs.cacert
                  nodejs
                  npm-deps
                  binaryen
                  wasmtime
                  cabal
                  (pkgs.callPackage ./pkgs/wasm32-wasi-cabal.nix { inherit flavour; })
                ];
            };
          wasm32-wasi-ghc-gmp = pkgs.callPackage ./pkgs/wasm32-wasi-ghc.nix { flavour = "gmp"; };
          wasm32-wasi-ghc-native = pkgs.callPackage ./pkgs/wasm32-wasi-ghc.nix { flavour = "native"; };
          wasm32-wasi-ghc-unreg = pkgs.callPackage ./pkgs/wasm32-wasi-ghc.nix { flavour = "unreg"; };
          wasm32-wasi-ghc-9_6 = pkgs.callPackage ./pkgs/wasm32-wasi-ghc.nix { flavour = "9.6"; };
          wasm32-wasi-ghc-9_8 = pkgs.callPackage ./pkgs/wasm32-wasi-ghc.nix { flavour = "9.8"; };
          wasm32-wasi-ghc-9_10 = pkgs.callPackage ./pkgs/wasm32-wasi-ghc.nix { flavour = "9.10"; };
          wasm32-wasi-ghc-9_12 = pkgs.callPackage ./pkgs/wasm32-wasi-ghc.nix { flavour = "9.12"; };
          wasm32-wasi-ghc-9_14 = pkgs.callPackage ./pkgs/wasm32-wasi-ghc.nix { flavour = "9.14"; };
          wasm32-wasi-cabal-gmp = pkgs.callPackage ./pkgs/wasm32-wasi-cabal.nix { flavour = "gmp"; };
          wasm32-wasi-cabal-native = pkgs.callPackage ./pkgs/wasm32-wasi-cabal.nix { flavour = "native"; };
          wasm32-wasi-cabal-unreg = pkgs.callPackage ./pkgs/wasm32-wasi-cabal.nix { flavour = "unreg"; };
          wasm32-wasi-cabal-9_6 = pkgs.callPackage ./pkgs/wasm32-wasi-cabal.nix { flavour = "9.6"; };
          wasm32-wasi-cabal-9_8 = pkgs.callPackage ./pkgs/wasm32-wasi-cabal.nix { flavour = "9.8"; };
          wasm32-wasi-cabal-9_10 = pkgs.callPackage ./pkgs/wasm32-wasi-cabal.nix { flavour = "9.10"; };
          wasm32-wasi-cabal-9_12 = pkgs.callPackage ./pkgs/wasm32-wasi-cabal.nix { flavour = "9.12"; };
          wasm32-wasi-cabal-9_14 = pkgs.callPackage ./pkgs/wasm32-wasi-cabal.nix { flavour = "9.14"; };
          wasi-sdk = pkgs.callPackage ./pkgs/wasi-sdk.nix { };
          nodejs = pkgs.nodejs_latest;
          npm-deps = pkgs.callPackage ./pkgs/npm-deps.nix { inherit nodejs; };
          binaryen = pkgs.callPackage ./pkgs/binaryen.nix { };
          wasmtime = pkgs.callPackage ./pkgs/wasmtime.nix { };
          cabal = pkgs.callPackage ./pkgs/cabal.nix { };
        in
        {
          packages = {
            inherit
              wasm32-wasi-ghc-gmp
              wasm32-wasi-ghc-native
              wasm32-wasi-ghc-unreg
              wasm32-wasi-ghc-9_6
              wasm32-wasi-ghc-9_8
              wasm32-wasi-ghc-9_10
              wasm32-wasi-ghc-9_12
              wasm32-wasi-ghc-9_14
              wasm32-wasi-cabal-gmp
              wasm32-wasi-cabal-native
              wasm32-wasi-cabal-unreg
              wasm32-wasi-cabal-9_6
              wasm32-wasi-cabal-9_8
              wasm32-wasi-cabal-9_10
              wasm32-wasi-cabal-9_12
              wasm32-wasi-cabal-9_14
              wasi-sdk
              nodejs
              npm-deps
              binaryen
              wasmtime
              cabal
              ;
            default = all "9.14";
            all_gmp = all "gmp";
            all_native = all "native";
            all_unreg = all "unreg";
            all_9_6 = all "9.6";
            all_9_8 = all "9.8";
            all_9_10 = all "9.10";
            all_9_12 = all "9.12";
            all_9_14 = all "9.14";
          };
        }
      );
}
