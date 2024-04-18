{ fetchurl
, hostPlatform
, lib
, runtimeShellPackage
, stdenvNoCC
, writeText
, zstd
}:
let
  wasmtime-key =
    if hostPlatform.isDarwin then
      if hostPlatform.isAarch64 then
        "wasmtime_aarch64_darwin"
      else
        "wasmtime_x86_64_darwin"
    else if hostPlatform.isAarch64 then
      "wasmtime_aarch64_linux"
    else
      "wasmtime";
  src = fetchurl
    ((builtins.fromJSON (builtins.readFile ../autogen.json))."${wasmtime-key}");
in
stdenvNoCC.mkDerivation {
  name = "wasmtime";

  inherit src;

  buildInputs = [ runtimeShellPackage ];

  nativeBuildInputs = [ zstd ];

  installPhase = ''
    runHook preInstall

    cp -R ./ $out

    install -Dm755 ${../wasm-run/wasmtime.sh} $out/bin/wasmtime.sh
    patchShebangs $out
    substituteInPlace $out/bin/wasmtime.sh \
      --replace wasmtime "$out/bin/wasmtime"

    runHook postInstall
  '';

  dontStrip = true;

  setupHook = writeText "wasmtime-setup-hook" ''
    addWasmtimeHook() {
      export CROSS_EMULATOR=@out@/bin/wasmtime.sh
    }

    addEnvHooks "$hostOffset" addWasmtimeHook
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    MIMALLOC_VERBOSE=1 $out/bin/wasmtime --version
  '';

  strictDeps = true;
}
