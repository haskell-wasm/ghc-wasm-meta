{ buildNpmPackage
, nodejs
,
}:
buildNpmPackage {
  name = "ghc-wasm-npm-deps";

  inherit nodejs;

  src = ../.;
  npmDepsHash = "sha512-zTbluExUr1sLXSYkBdAwHyI77Z2eo1tlrp97VVMfGufrZU8Gvb+BmCGv0mQPpQ0/SN7l9PpjcwG1D+dhpgPnYA==";

  dontNpmBuild = true;
  dontNpmInstall = true;

  installPhase = ''
    runHook preInstall

    cp -R node_modules $out

    runHook postInstall
  '';

  strictDeps = true;
}
