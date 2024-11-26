{ coreutils
, lib
, callPackage
, flavour
, writeShellScriptBin
,
}:
let
  cabal = callPackage ./cabal.nix { };
  wasm32-wasi-ghc = callPackage ./wasm32-wasi-ghc.nix { inherit flavour; };
  init-cabal-config =
    lib.optionalString
      (
        (lib.elem flavour [
          "gmp"
          "native"
          "unreg"
        ])
      )
      ''
        ${coreutils}/bin/cp ${../cabal.head.config} "$CABAL_DIR/config"
        ${coreutils}/bin/chmod u+w "$CABAL_DIR/config"
      ''
    +
    lib.optionalString
      (lib.elem flavour [
        "9.10"
        "9.12"
      ])
      ''
        ${coreutils}/bin/cp ${../cabal.th.config} "$CABAL_DIR/config"
        ${coreutils}/bin/chmod u+w "$CABAL_DIR/config"
      ''
    +
    lib.optionalString
      (lib.elem flavour [
        "9.6"
        "9.8"
      ])
      ''
        ${coreutils}/bin/cp ${../cabal.legacy.config} "$CABAL_DIR/config"
        ${coreutils}/bin/chmod u+w "$CABAL_DIR/config"
      '';
in
writeShellScriptBin "wasm32-wasi-cabal" ''
  export CABAL_DIR="''${CABAL_DIR:-$HOME/.ghc-wasm/.cabal}"

  if [ ! -f "$CABAL_DIR/config" ]
  then
    ${coreutils}/bin/mkdir -p "$CABAL_DIR"
    ${init-cabal-config}
  fi

  exec ${cabal}/bin/cabal \
    --with-compiler=${wasm32-wasi-ghc}/bin/wasm32-wasi-ghc \
    --with-hc-pkg=${wasm32-wasi-ghc}/bin/wasm32-wasi-ghc-pkg \
    --with-hsc2hs=${wasm32-wasi-ghc}/bin/wasm32-wasi-hsc2hs \
    ''${1+"$@"}
''
