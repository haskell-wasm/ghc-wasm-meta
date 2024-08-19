{
  fetchurl,
  hostPlatform,
  runtimeShellPackage,
  stdenv,
  stdenvNoCC,
  unzip,
}:
let
  common-src = builtins.fromJSON (builtins.readFile ../autogen.json);
  wasi-sdk-key =
    if hostPlatform.isDarwin then
      if hostPlatform.isAarch64 then "wasi-sdk-aarch64-darwin" else "wasi-sdk-x86_64-darwin"
    else if hostPlatform.isAarch64 then
      "wasi-sdk-aarch64-linux"
    else
      "wasi-sdk";
  wasi-sdk-src = fetchurl common-src."${wasi-sdk-key}";
  libffi-wasm-src = fetchurl (common-src.libffi-wasm // { name = "libffi-wasm.zip"; });
in
stdenvNoCC.mkDerivation {
  name = "wasi-sdk";

  srcs = [
    wasi-sdk-src
    libffi-wasm-src
  ];
  setSourceRoot = "sourceRoot=$(echo wasi-sdk-*)";

  nativeBuildInputs = [ unzip ];
  buildInputs = [ runtimeShellPackage ];

  cc_for_build = "${stdenv.cc}/bin/cc";

  installPhase = ''
    runHook preInstall

    cp -a . $out
    chmod -R u+w $out

    mkdir $out/nix-support
    substituteAll ${./wasi-sdk-setup-hook.sh} $out/nix-support/setup-hook

    patchShebangs $out

    cp -a ../out/libffi-wasm/include/. $out/share/wasi-sysroot/include/wasm32-wasi
    cp -a ../out/libffi-wasm/lib/. $out/share/wasi-sysroot/lib/wasm32-wasi

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    pushd "$(mktemp -d)"
    echo '#include <iostream>' >> test.cpp
    echo 'void ffi_alloc_prep_closure(void);' >> test.cpp
    echo 'int main(void) { std::cout << &ffi_alloc_prep_closure << std::endl; }' >> test.cpp
    $out/bin/wasm32-wasi-clang++ test.cpp -lffi -o test.wasm
    popd

    runHook postInstallCheck
  '';

  dontFixup = true;

  allowedReferences = [
    "out"
    runtimeShellPackage
    stdenv.cc
  ];
}
