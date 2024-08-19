{
  autoPatchelfHook,
  fetchurl,
  fixDarwinDylibNames,
  hostPlatform,
  lib,
  ncurses,
  stdenv,
  zlib,
}:
let
  src = fetchurl ((builtins.fromJSON (builtins.readFile ../autogen.json))."${key}");
  key =
    {
      x86_64-linux = "wasmedge";
      aarch64-linux = "wasmedge_aarch64_linux";
      aarch64-darwin = "wasmedge_aarch64_darwin";
      x86_64-darwin = "wasmedge_x86_64_darwin";
    }
    ."${hostPlatform.system}";
in
stdenv.mkDerivation {
  name = "wasmedge";
  inherit src;
  buildInputs = [
    ncurses
    stdenv.cc.cc.lib
    zlib
  ];
  nativeBuildInputs =
    lib.optionals hostPlatform.isLinux [ autoPatchelfHook ]
    ++ lib.optionals hostPlatform.isDarwin [ fixDarwinDylibNames ];
  installPhase = ''
    runHook preInstall

    cp -R ./ $out

    runHook postInstall
  '';
  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/wasmedge --version
  '';
  strictDeps = true;
}
