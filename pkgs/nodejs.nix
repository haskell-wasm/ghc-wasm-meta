{ fetchurl
, fixDarwinDylibNames
, hostPlatform
, lib
, python3
, stdenvNoCC
,
}:
let
  src = fetchurl ((builtins.fromJSON (builtins.readFile ../autogen.json))."${key}");
  key =
    {
      x86_64-linux = "nodejs";
      aarch64-linux = "nodejs_aarch64_linux";
      aarch64-darwin = "nodejs_aarch64_darwin";
      x86_64-darwin = "nodejs_x86_64_darwin";
    }."${hostPlatform.system}";
in
stdenvNoCC.mkDerivation {
  name = "nodejs";
  version = "23.10.0";

  inherit src;
  nativeBuildInputs = lib.optionals hostPlatform.isDarwin [ fixDarwinDylibNames ];
  installPhase = ''
    runHook preInstall

    cp -R ./ $out

    substituteInPlace $out/bin/corepack \
      --replace "/usr/bin/env node" "$out/bin/node"
    substituteInPlace $out/bin/npm \
      --replace "/usr/bin/env node" "$out/bin/node"
    substituteInPlace $out/bin/npx \
      --replace "/usr/bin/env node" "$out/bin/node"

    runHook postInstall
  '';
  doInstallCheck = true;
  installCheckPhase = ''
    MIMALLOC_VERBOSE=1 $out/bin/node --version
    $out/bin/npm --version
  '';
  strictDeps = true;

  meta = with lib; {
    platforms = platforms.linux ++ platforms.darwin;
    mainProgram = "node";
  };

  passthru.python = python3;
}
