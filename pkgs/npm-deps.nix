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
  npmDepsHash = "sha512-O5topXdf3jkD5lv52DLKXexbVNuoejDHUuwXzz317KG6V4+bsDepbfMexRAzgfX11zzjYpmVBdicUYWqutL9pw==";

  dontNpmBuild = true;

  strictDeps = true;
}
