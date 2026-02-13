{ lib
, callPackage
, flavour
, writeShellScriptBin
}:
let
  cabal = callPackage ./cabal.nix { };
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
        cp "${../cabal.head.config}" "$CABAL_DIR/config"
        chmod u+w "$CABAL_DIR/config"
      ''
    +
    lib.optionalString
      (lib.elem flavour [
        "9.10"
        "9.12"
        "9.14"
      ])
      ''
        cp "${../cabal.th.config}" "$CABAL_DIR/config"
        chmod u+w "$CABAL_DIR/config"
      ''
    +
    lib.optionalString
      (lib.elem flavour [
        "9.6"
        "9.8"
      ])
      ''
        cp "${../cabal.legacy.config}" "$CABAL_DIR/config"
        chmod u+w "$CABAL_DIR/config"
      '';
  withHaddock = lib.optionalString
    (
      !lib.elem flavour [
        "9.6"
        "9.8"
      ]
    ) "--with-haddock=wasm32-wasi-haddock";
in
writeShellScriptBin "wasm32-wasi-cabal" ''
  export CABAL_DIR="''${CABAL_DIR:-$HOME/.ghc-wasm/.cabal}"

  if [ ! -f "$CABAL_DIR/config" ]
  then
    mkdir -p "$CABAL_DIR"
    ${init-cabal-config}
  fi

  exec ${cabal}/bin/cabal \
    --with-compiler=wasm32-wasi-ghc \
    --with-hc-pkg=wasm32-wasi-ghc-pkg \
    --with-hsc2hs=wasm32-wasi-hsc2hs \
    ${withHaddock} \
    ''${1+"$@"}
''
