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
  npmDepsHash = "sha512-q2WgSNGJev8WaBSGgMvNeUd4leb22CaUmmMh6u/oenMO5o6WTVvGaUbD4JYhxjStStwClNRUauhwM+bXgpyvSA==";

  dontNpmBuild = true;

  strictDeps = true;
}
