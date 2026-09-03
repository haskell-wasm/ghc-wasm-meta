{ autoPatchelfHook
, buildNpmPackage
, fixDarwinDylibNames
, lib
, musl
, nodejs
, stdenv
,
}:
buildNpmPackage {
  pname = "ghc-wasm-npm-deps";
  version = "0.0.1";

  inherit nodejs;

  src = lib.sourceFilesBySuffices ../. [
    "package.json"
    "package-lock.json"
  ];
  npmDepsHash = "sha256-62SAYAT+KmF9CUCMTovMb+gsWIKcQGADbxXm8B0JEjo=";

  nativeBuildInputs =
    lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [ fixDarwinDylibNames ];
  buildInputs = [ stdenv.cc.cc.lib ] ++ lib.optionals stdenv.hostPlatform.isLinux [ musl ];

  dontNpmBuild = true;
  postInstall = ''
    mkdir $out/bin
    pushd $out/lib/node_modules/@haskell-wasm/ghc-wasm-npm-deps/node_modules/.bin
    for b in *; do
      ln -s $out/lib/node_modules/@haskell-wasm/ghc-wasm-npm-deps/node_modules/.bin/$b $out/bin/$b
    done
    popd
  '';
  dontStrip = false;
}
