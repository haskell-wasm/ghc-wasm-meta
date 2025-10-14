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
  npmDepsHash = "sha512-r6x6BDGq1G3l1LwGZKo2J5hJX3u/Z4QZut1+ZHpm//NqmRTTJ9Q23q9E7+Fm4FIp9q1vnbdk4VlV6mkQZHYx7Q==";

  dontNpmBuild = true;
  dontNpmInstall = true;

  installPhase = ''
    runHook preInstall

    cp -R node_modules $out

    runHook postInstall
  '';

  strictDeps = true;
}
