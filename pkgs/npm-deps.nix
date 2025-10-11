{ buildNpmPackage
, lib
, nodejs
,
}:
buildNpmPackage {
  name = "ghc-wasm-npm-deps";

  inherit nodejs;

  src = lib.sourceFilesBySuffices ../. [
    "package.json"
    "package-lock.json"
  ];
  npmDepsHash = "sha512-gbCd3hlPyA4Y+2bPolh6jeEGOuWradZAKoqLKmVAXBjxIr9NTbyfREXH2D5D3vI3vYlzF6QpI8p+MpiL4TfqCA==";

  dontNpmBuild = true;
  dontNpmInstall = true;

  installPhase = ''
    runHook preInstall

    cp -R node_modules $out

    runHook postInstall
  '';

  strictDeps = true;
}
