{
  callPackage,
  coreutils,
  fetchurl,
  flavour,
  hostPlatform,
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
    wasi-sdk
    zstd
  ];
  buildInputs = [ runtimeShellPackage ];

  preConfigure = ''
    substituteInPlace lib/*.mjs \
      --replace '/usr/bin/env -S node' "${coreutils}/bin/env -S ${nodejs}/bin/node"

    patchShebangs .

    configureFlags="$configureFlags --build=$system --host=$system $CONFIGURE_ARGS"
  '';

  configurePlatforms = [ ];

  postInstall = ''
    pushd $out/lib/wasm32-wasi-ghc-*/lib
    touch dyld.mjs
    mv dyld.mjs dyld.real.mjs
    echo "#!${runtimeShell}" >> dyld.mjs
    echo "exec ${nodejs}/bin/node --disable-warning=ExperimentalWarning --experimental-wasm-type-reflection --max-old-space-size=65536 --no-turbo-fast-api-calls --wasm-lazy-validation $PWD/dyld.real.mjs" '$@' >> dyld.mjs
    chmod +x dyld.mjs
    popd
  '';

  dontBuild = true;
  dontFixup = true;
  strictDeps = true;
}
