#!/usr/bin/env bash

set -euo pipefail

FLAVOUR="${FLAVOUR:-gmp}"
REPO=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
SKIP_GHC="${SKIP_GHC:-}"

if [[ -z "${PREFIX:-}" ]]; then
  PREFIX="$HOME/.ghc-wasm"
fi

host_specific() {
  if [[ $(uname -s) == "Linux" && $(uname -m) == "x86_64" ]]; then
    HOST="x86_64-linux"
    WASI_SDK="wasi-sdk"
    WASMTIME="wasmtime"
    WASMEDGE="wasmedge"
    WAZERO="wazero"
    NODEJS="nodejs"
    DENO="deno"
    BUN="bun"
    CABAL="cabal"
    BINARYEN="binaryen"
    GHC="wasm32-wasi-ghc-$FLAVOUR"
  fi

  if [[ $(uname -s) == "Linux" && $(uname -m) == "aarch64" ]]; then
    HOST="aarch64-linux"
    WASI_SDK="wasi-sdk-aarch64-linux"
    WASMTIME="wasmtime_aarch64_linux"
    WASMEDGE="wasmedge_aarch64_linux"
    WAZERO="wazero_aarch64_linux"
    NODEJS="nodejs_aarch64_linux"
    DENO="deno_aarch64_linux"
    BUN="bun_aarch64_linux"
    CABAL="cabal_aarch64_linux"
    BINARYEN="binaryen_aarch64_linux"
    GHC="wasm32-wasi-ghc-gmp-aarch64-linux"
    FLAVOUR="gmp"
  fi

  if [[ $(uname -s) == "Darwin" && $(uname -m) == "arm64" ]]; then
    HOST="aarch64-apple-darwin"
    WASI_SDK="wasi-sdk-aarch64-darwin"
    WASMTIME="wasmtime_aarch64_darwin"
    WASMEDGE="wasmedge_aarch64_darwin"
    WAZERO="wazero_aarch64_darwin"
    NODEJS="nodejs_aarch64_darwin"
    DENO="deno_aarch64_darwin"
    BUN="bun_aarch64_darwin"
    CABAL="cabal_aarch64_darwin"
    BINARYEN="binaryen_aarch64_darwin"
    GHC="wasm32-wasi-ghc-gmp-aarch64-darwin"
    FLAVOUR="gmp"
  fi

  if [[ $(uname -s) == "Darwin" && $(uname -m) == "x86_64" ]]; then
    HOST="x86_64-apple-darwin"
    WASI_SDK="wasi-sdk-x86_64-darwin"
    WASMTIME="wasmtime_x86_64_darwin"
    WASMEDGE="wasmedge_x86_64_darwin"
    WAZERO="wazero_x86_64_darwin"
    NODEJS="nodejs_x86_64_darwin"
    DENO="deno_x86_64_darwin"
    BUN="bun_x86_64_darwin"
    CABAL="cabal_x86_64_darwin"
    BINARYEN="binaryen_x86_64_darwin"
    GHC="wasm32-wasi-ghc-gmp-x86_64-darwin"
    FLAVOUR="gmp"
  fi
}

host_specific

# wtf macos
# PREFIX=$(realpath "$PREFIX")

rm -rf "$PREFIX"

workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT

pushd "$workdir"

mkdir -p "$PREFIX/wasi-sdk"
curl -f -L --retry 5 "$(jq -r ".\"$WASI_SDK\".url" "$REPO"/autogen.json)" | tar xz -C "$PREFIX/wasi-sdk" --no-same-owner --strip-components=1

curl -f -L --retry 5 "$(jq -r '."libffi-wasm".url' "$REPO"/autogen.json)" -o out.zip
unzip out.zip
cp -a out/libffi-wasm/include/. "$PREFIX/wasi-sdk/share/wasi-sysroot/include/wasm32-wasi"
cp -a out/libffi-wasm/lib/. "$PREFIX/wasi-sdk/share/wasi-sysroot/lib/wasm32-wasi"

curl -f -L --retry 5 "$(jq -r ".\"$DENO\".url" "$REPO"/autogen.json)" -o deno.zip
unzip deno.zip
mkdir -p "$PREFIX/deno/bin"
install -m755 deno "$PREFIX/deno/bin"

mkdir -p "$PREFIX/nodejs"
curl -f -L --retry 5 "$(jq -r ".\"$NODEJS\".url" "$REPO"/autogen.json)" | tar xJ -C "$PREFIX/nodejs" --no-same-owner --strip-components=1

curl -f -L --retry 5 "$(jq -r ".\"$BUN\".url" "$REPO"/autogen.json)" -o bun.zip
unzip bun.zip
mkdir -p "$PREFIX/bun/bin"
install -m755 bun-*/bun "$PREFIX/bun/bin"

mkdir -p "$PREFIX/binaryen"
curl -f -L --retry 5 "$(jq -r ".\"$BINARYEN\".url" "$REPO"/autogen.json)" | tar xz -C "$PREFIX/binaryen" --no-same-owner --strip-components=1

mkdir -p "$PREFIX/wabt"
curl -f -L --retry 5 "$(jq -r .wabt.url "$REPO"/autogen.json)" | tar xz -C "$PREFIX/wabt" --no-same-owner --strip-components=1

mkdir -p "$PREFIX/wasmtime"
curl -f -L --retry 5 "$(jq -r ".\"$WASMTIME\".url" "$REPO"/autogen.json)" | tar x --zstd -C "$PREFIX/wasmtime" --no-same-owner --strip-components=1

mkdir -p "$PREFIX/wasmedge"
curl -f -L --retry 5 "$(jq -r ".\"$WASMEDGE\".url" "$REPO"/autogen.json)" | tar xz -C "$PREFIX/wasmedge" --no-same-owner --strip-components=1

mkdir -p "$PREFIX/wazero/bin"
curl -f -L --retry 5 "$(jq -r ".\"$WAZERO\".url" "$REPO"/autogen.json)" | tar xz -C "$PREFIX/wazero/bin" --no-same-owner

mkdir -p "$PREFIX/proot/bin"
curl -f -L --retry 5 "$(jq -r .proot.url "$REPO"/autogen.json)" -o "$PREFIX/proot/bin/proot"
chmod 755 "$PREFIX/proot/bin/proot"

mkdir -p "$PREFIX/wasm-run/bin"
cp -a "$REPO"/wasm-run/*.js "$REPO"/wasm-run/*.mjs "$REPO"/wasm-run/*.sh "$PREFIX/wasm-run/bin"
cc -DWASM_RUN="\"$PREFIX/wasm-run/bin/wasm-run.js\"" -Wall -O3 "$REPO/wasm-run/qemu-system-wasm32.c" -o "$PREFIX/wasm-run/bin/qemu-system-wasm32"
echo "#!/bin/sh" >> "$PREFIX/wasm-run/bin/wasm-run"
echo "exec $PREFIX/proot/bin/proot -q $PREFIX/wasm-run/bin/qemu-system-wasm32" '${1+"$@"}' >> "$PREFIX/wasm-run/bin/wasm-run"
chmod 755 "$PREFIX/wasm-run/bin/wasm-run"
sed -i -e "s@wasmtime@$PREFIX/wasmtime/bin/wasmtime@" "$PREFIX/wasm-run/bin/wasmtime.sh"

echo "#!/bin/sh" >> "$PREFIX/add_to_github_path.sh"
chmod 755 "$PREFIX/add_to_github_path.sh"

for p in \
  "$PREFIX/wasm-run/bin" \
  "$PREFIX/proot/bin" \
  "$PREFIX/wasm32-wasi-cabal/bin" \
  "$PREFIX/cabal/bin" \
  "$PREFIX/wazero/bin" \
  "$PREFIX/wasmedge/bin" \
  "$PREFIX/wasmtime/bin" \
  "$PREFIX/wabt/bin" \
  "$PREFIX/binaryen/bin" \
  "$PREFIX/bun/bin" \
  "$PREFIX/nodejs/bin" \
  "$PREFIX/deno/bin" \
  "$PREFIX/wasi-sdk/bin" \
  "$PREFIX/wasm32-wasi-ghc/bin"
do
  echo "export PATH=$p:\$PATH" >> "$PREFIX/env"
  echo "echo $p >> \$GITHUB_PATH" >> "$PREFIX/add_to_github_path.sh"
done

for e in \
  "AR=$PREFIX/wasi-sdk/bin/llvm-ar" \
  "CC=$PREFIX/wasi-sdk/bin/wasm32-wasi-clang" \
  "CC_FOR_BUILD=cc" \
  "CXX=$PREFIX/wasi-sdk/bin/wasm32-wasi-clang++" \
  "LD=$PREFIX/wasi-sdk/bin/wasm-ld" \
  "NM=$PREFIX/wasi-sdk/bin/llvm-nm" \
  "OBJCOPY=$PREFIX/wasi-sdk/bin/llvm-objcopy" \
  "OBJDUMP=$PREFIX/wasi-sdk/bin/llvm-objdump" \
  "RANLIB=$PREFIX/wasi-sdk/bin/llvm-ranlib" \
  "SIZE=$PREFIX/wasi-sdk/bin/llvm-size" \
  "STRINGS=$PREFIX/wasi-sdk/bin/llvm-strings" \
  "STRIP=$PREFIX/wasi-sdk/bin/llvm-strip" \
  "LLC=/bin/false" \
  "OPT=/bin/false"
do
  echo "export $e" >> "$PREFIX/env"
  echo "echo $e >> \$GITHUB_ENV" >> "$PREFIX/add_to_github_path.sh"
done

for e in \
  'CONF_CC_OPTS_STAGE2=${CONF_CC_OPTS_STAGE2:-"-fno-strict-aliasing -Wno-error=int-conversion -O3 -msimd128 -mnontrapping-fptoint -msign-ext -mbulk-memory -mmutable-globals -mmultivalue -mreference-types"}' \
  'CONF_CXX_OPTS_STAGE2=${CONF_CXX_OPTS_STAGE2:-"-fno-exceptions -fno-strict-aliasing -Wno-error=int-conversion -O3 -msimd128 -mnontrapping-fptoint -msign-ext -mbulk-memory -mmutable-globals -mmultivalue -mreference-types"}' \
  'CONF_GCC_LINKER_OPTS_STAGE2=${CONF_GCC_LINKER_OPTS_STAGE2:-"-Wl,--compress-relocations,--error-limit=0,--keep-section=ghc_wasm_jsffi,--strip-all "}' \
  'CONF_CC_OPTS_STAGE1=${CONF_CC_OPTS_STAGE1:-"-fno-strict-aliasing -Wno-error=int-conversion -O3 -msimd128 -mnontrapping-fptoint -msign-ext -mbulk-memory -mmutable-globals -mmultivalue -mreference-types"}' \
  'CONF_CXX_OPTS_STAGE1=${CONF_CXX_OPTS_STAGE1:-"-fno-exceptions -fno-strict-aliasing -Wno-error=int-conversion -O3 -msimd128 -mnontrapping-fptoint -msign-ext -mbulk-memory -mmutable-globals -mmultivalue -mreference-types"}' \
  'CONF_GCC_LINKER_OPTS_STAGE1=${CONF_GCC_LINKER_OPTS_STAGE1:-"-Wl,--compress-relocations,--error-limit=0,--keep-section=ghc_wasm_jsffi,--strip-all "}' \
  "CONFIGURE_ARGS=\"--host=$HOST --target=wasm32-wasi --with-intree-gmp --with-system-libffi\"" \
  'CROSS_EMULATOR=${CROSS_EMULATOR:-"'"$PREFIX/wasm-run/bin/wasm-run.mjs"'"}'
do
  echo "export $e" >> "$PREFIX/env"
  echo "echo $e >> \$GITHUB_ENV" >> "$PREFIX/add_to_github_path.sh"
done

if [[ -n "${SKIP_GHC}" ]]
then
	exit
fi

mkdir -p "$PREFIX/wasm32-wasi-ghc"
mkdir ghc
if [[ $(uname -s) == "Linux" && $(uname -m) == "x86_64" ]]; then
  curl -f -L --retry 5 "$(jq -r ".\"$GHC\".url" "$REPO"/autogen.json)" | tar xJ -C ghc --no-same-owner --strip-components=1
else
  curl -f -L --retry 5 "$(jq -r ".\"$GHC\".url" "$REPO"/autogen.json)" | tar x --zstd -C ghc --no-same-owner --strip-components=1
fi
pushd ghc
sh -c ". $PREFIX/env && ./configure \$CONFIGURE_ARGS --prefix=$PREFIX/wasm32-wasi-ghc && exec make install"
popd

mkdir -p "$PREFIX/cabal/bin"
curl -f -L --retry 5 "$(jq -r ".\"$CABAL\".url" "$REPO"/autogen.json)" | tar xJ --no-same-owner -C "$PREFIX/cabal/bin" 'cabal'

mkdir -p "$PREFIX/wasm32-wasi-cabal/bin"
echo "#!/bin/sh" >> "$PREFIX/wasm32-wasi-cabal/bin/wasm32-wasi-cabal"
echo \
  "CABAL_DIR=$PREFIX/.cabal" \
  "exec" \
  "$PREFIX/cabal/bin/cabal" \
  "--with-compiler=$PREFIX/wasm32-wasi-ghc/bin/wasm32-wasi-ghc" \
  "--with-hc-pkg=$PREFIX/wasm32-wasi-ghc/bin/wasm32-wasi-ghc-pkg" \
  "--with-hsc2hs=$PREFIX/wasm32-wasi-ghc/bin/wasm32-wasi-hsc2hs" \
  '${1+"$@"}' >> "$PREFIX/wasm32-wasi-cabal/bin/wasm32-wasi-cabal"
chmod 755 "$PREFIX/wasm32-wasi-cabal/bin/wasm32-wasi-cabal"

mkdir "$PREFIX/.cabal"
if [[ "$FLAVOUR" != 9.6 ]] && [[ "$FLAVOUR" != 9.8 ]] && [[ "$FLAVOUR" != 9.10 ]]
then
  cp "$REPO/cabal.config" "$PREFIX/.cabal/config"
fi
"$PREFIX/wasm32-wasi-cabal/bin/wasm32-wasi-cabal" update

popd

echo "Everything set up in $PREFIX."
echo "Run 'source $PREFIX/env' to add tools to your PATH."
