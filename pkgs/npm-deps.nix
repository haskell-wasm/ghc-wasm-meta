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
  npmDepsHash = "sha512-ZvT/qqaCwbrM1drx/8ukWOeqxSObLeZn9KqkSamEmHtjtQflBQlXCzCi6Ut97GqxGlNDIGq7oN1mnBsgkSLNmw==";

  dontNpmBuild = true;
  dontNpmInstall = true;

  installPhase = ''
    runHook preInstall

    cp -R node_modules $out

    runHook postInstall
  '';

  strictDeps = true;
}
