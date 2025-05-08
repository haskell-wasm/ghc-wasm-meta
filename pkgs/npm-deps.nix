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
  npmDepsHash = "sha512-dIrmbHAo0D+aWqgxdXP6IHTRM7ZsTnTPdo8Yns+W7n3zkIxEfqEDotsYALrlKK7Jta8yFu89yyBoJ8ZS7ldNzA==";

  dontNpmBuild = true;
  dontNpmInstall = true;

  installPhase = ''
    runHook preInstall

    cp -R node_modules $out

    runHook postInstall
  '';

  strictDeps = true;
}
