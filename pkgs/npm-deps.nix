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
  npmDepsHash = "sha512-HV5jfUu3B1mvtgGBhUBraqUF4yp+XPGZFIVTuq4zTcmMKKdkBgLujiz+qMqb07ewjMZr0L2nYEsolrxVIBWbGw==";

  dontNpmBuild = true;
  dontNpmInstall = true;

  installPhase = ''
    runHook preInstall

    cp -R node_modules $out

    runHook postInstall
  '';

  strictDeps = true;
}
