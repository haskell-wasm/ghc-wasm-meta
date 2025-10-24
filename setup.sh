#!/usr/bin/env bash

set -euo pipefail

FLAVOUR="${FLAVOUR:-9.14}"
REPO=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
SKIP_GHC="${SKIP_GHC:-}"

if [[ -z "${PREFIX:-}" ]]; then
  PREFIX="$HOME/.ghc-wasm"
fi

host_specific() {
  if [[ $(uname -s) == "Linux" && $(uname -m) == "x86_64" ]]; then
    HOST="x86_64-linux"
    WASI_SDK="wasi-sdk"
    WASI_SDK_JOB_NAME="x86_64-linux"
    WASI_SDK_ARTIFACT_PATH="dist/wasi-sdk-27.0-x86_64-linux.tar.gz"
    WASMTIME="wasmtime"
    NODEJS="nodejs"
    CABAL="cabal"
    BINARYEN="binaryen"
    GHC="wasm32-wasi-ghc-$FLAVOUR"
  fi

  if [[ $(uname -s) == "Linux" && $(uname -m) == "aarch64" ]]; then
    HOST="aarch64-linux"
    WASI_SDK="wasi-sdk-aarch64-linux"
    WASI_SDK_JOB_NAME="aarch64-linux"
    WASI_SDK_ARTIFACT_PATH="dist/wasi-sdk-27.0-aarch64-linux.tar.gz"
    WASMTIME="wasmtime_aarch64_linux"
    NODEJS="nodejs_aarch64_linux"
    CABAL="cabal_aarch64_linux"
    BINARYEN="binaryen_aarch64_linux"
    if [[ "$FLAVOUR" == 9.10 ]]; then
      GHC="wasm32-wasi-ghc-gmp-aarch64-linux-9.10"
    elif [[ "$FLAVOUR" == 9.12 ]]; then
      GHC="wasm32-wasi-ghc-gmp-aarch64-linux-9.12"
    elif [[ "$FLAVOUR" == 9.14 ]]; then
      GHC="wasm32-wasi-ghc-gmp-aarch64-linux-9.14"
    else
      echo "No prebuilt GHC wasm bindist with flavour $FLAVOUR on aarch64-linux"
      exit 1
    fi
  fi

  if [[ $(uname -s) == "Darwin" ]]; then
    if [[ "${NIX_SYSTEM:-}" == "x86_64-darwin" || $(uname -m) == "x86_64" ]]; then
      HOST="x86_64-apple-darwin"
      WASI_SDK="wasi-sdk-x86_64-darwin"
      WASI_SDK_JOB_NAME="x86_64-darwin"
      WASI_SDK_ARTIFACT_PATH="dist/wasi-sdk-27.0-arm64-macos.tar.gz"
      WASMTIME="wasmtime_x86_64_darwin"
      NODEJS="nodejs_x86_64_darwin"
      CABAL="cabal_x86_64_darwin"
      BINARYEN="binaryen_x86_64_darwin"
      if [[ "$FLAVOUR" == 9.10 ]]; then
        GHC="wasm32-wasi-ghc-gmp-x86_64-darwin-9.10"
      elif [[ "$FLAVOUR" == 9.12 ]]; then
        GHC="wasm32-wasi-ghc-gmp-x86_64-darwin-9.12"
      elif [[ "$FLAVOUR" == 9.14 ]]; then
        GHC="wasm32-wasi-ghc-gmp-x86_64-darwin-9.14"
      else
        echo "No prebuilt GHC wasm bindist with flavour $FLAVOUR on x86_64-darwin"
        exit 1
      fi
    else
      HOST="aarch64-apple-darwin"
      WASI_SDK="wasi-sdk-aarch64-darwin"
      WASI_SDK_JOB_NAME="aarch64-darwin"
      WASI_SDK_ARTIFACT_PATH="dist/wasi-sdk-27.0-arm64-macos.tar.gz"
      WASMTIME="wasmtime_aarch64_darwin"
      NODEJS="nodejs_aarch64_darwin"
      CABAL="cabal_aarch64_darwin"
      BINARYEN="binaryen_aarch64_darwin"
      if [[ "$FLAVOUR" == 9.10 ]]; then
        GHC="wasm32-wasi-ghc-gmp-aarch64-darwin-9.10"
      elif [[ "$FLAVOUR" == 9.12 ]]; then
        GHC="wasm32-wasi-ghc-gmp-aarch64-darwin-9.12"
      elif [[ "$FLAVOUR" == 9.14 ]]; then
        GHC="wasm32-wasi-ghc-gmp-aarch64-darwin-9.14"
      else
        echo "No prebuilt GHC wasm bindist with flavour $FLAVOUR on aarch64-darwin"
        exit 1
      fi
    fi
  fi
}

host_specific

SED_IS_GNU=$(sed --version &> /dev/null && echo 1 || echo 0)

# wtf macos
# PREFIX=$(realpath "$PREFIX")

rm -rf "$PREFIX"

workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT

pushd "$workdir"

if [[ -z "${UPSTREAM_WASI_SDK_PIPELINE_ID:-}" ]]; then
  WASI_SDK_BINDIST=$(jq -r ".\"$WASI_SDK\".url" "$REPO"/autogen.json)
else
  UPSTREAM_WASI_SDK_JOB_ID=$(curl -f -L --retry 5 https://gitlab.haskell.org/api/v4/projects/3212/pipelines/$UPSTREAM_WASI_SDK_PIPELINE_ID/jobs?scope[]=success | jq -r ".[] | select(.name == \"$WASI_SDK_JOB_NAME\") | .id")
  WASI_SDK_BINDIST=https://gitlab.haskell.org/haskell-wasm/wasi-sdk/-/jobs/$UPSTREAM_WASI_SDK_JOB_ID/artifacts/raw/$WASI_SDK_ARTIFACT_PATH
fi
echo "Installing wasi-sdk from $WASI_SDK_BINDIST"
mkdir -p "$PREFIX/wasi-sdk"
curl -f -L --retry 5 "$WASI_SDK_BINDIST" -o wasi-sdk.tar.gz
tar xzf wasi-sdk.tar.gz -C "$PREFIX/wasi-sdk" --no-same-owner --strip-components=1

curl -f -L --retry 5 "$(jq -r '."libffi-wasm".url' "$REPO"/autogen.json)" -o out.zip
unzip out.zip
cp -a out/libffi-wasm/include/. "$PREFIX/wasi-sdk/share/wasi-sysroot/include/wasm32-wasi"
cp -a out/libffi-wasm/lib/. "$PREFIX/wasi-sdk/share/wasi-sysroot/lib/wasm32-wasi"

mkdir -p "$PREFIX/nodejs"
curl -f -L --retry 5 "$(jq -r ".\"$NODEJS\".url" "$REPO"/autogen.json)" -o nodejs.tar.xz
tar xJf nodejs.tar.xz -C "$PREFIX/nodejs" --no-same-owner --strip-components=1
"$PREFIX/nodejs/bin/node" "$PREFIX/nodejs/bin/npm" install -g --prefix "$PREFIX/nodejs" \
  puppeteer-core@^24.26.1 \
  ws@^8.18.3
if [[ -n "${PLAYWRIGHT:-}" ]]; then
  "$PREFIX/nodejs/bin/node" "$PREFIX/nodejs/bin/npm" install -g --prefix "$PREFIX/nodejs" \
    playwright
  PATH=$PREFIX/nodejs/bin:$PATH playwright install --with-deps --no-shell
fi

mkdir -p "$PREFIX/binaryen"
curl -f -L --retry 5 "$(jq -r ".\"$BINARYEN\".url" "$REPO"/autogen.json)" -o binaryen.tar.gz
tar xzf binaryen.tar.gz -C "$PREFIX/binaryen" --no-same-owner --strip-components=1

mkdir -p "$PREFIX/wasmtime"
curl -f -L --retry 5 "$(jq -r ".\"$WASMTIME\".url" "$REPO"/autogen.json)" -o wasmtime.tar.zst
unzstd wasmtime.tar.zst -o wasmtime.tar
tar xf wasmtime.tar -C "$PREFIX/wasmtime" --no-same-owner --strip-components=1

mkdir -p "$PREFIX/wasm-run/bin"
cp -a "$REPO"/wasm-run/*.mjs "$REPO"/wasm-run/*.sh "$PREFIX/wasm-run/bin"
if [[ $SED_IS_GNU == "1" ]]; then
  sed -i "s@wasmtime@$PREFIX/wasmtime/bin/wasmtime@" "$PREFIX/wasm-run/bin/wasmtime.sh"
else
  sed -i "" "s@wasmtime@$PREFIX/wasmtime/bin/wasmtime@" "$PREFIX/wasm-run/bin/wasmtime.sh"
fi

echo "#!/bin/sh" >> "$PREFIX/add_to_github_path.sh"
chmod 755 "$PREFIX/add_to_github_path.sh"

for p in \
  "$PREFIX/wasm-run/bin" \
  "$PREFIX/wasm32-wasi-cabal/bin" \
  "$PREFIX/wasmtime/bin" \
  "$PREFIX/binaryen/bin" \
  "$PREFIX/nodejs/bin" \
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
  'CONF_CC_OPTS_STAGE2=${CONF_CC_OPTS_STAGE2:-"-Wno-error=int-conversion -O3 -mcpu=lime1 -mreference-types -msimd128"}' \
  'CONF_CXX_OPTS_STAGE2=${CONF_CXX_OPTS_STAGE2:-"-fno-exceptions -Wno-error=int-conversion -O3 -mcpu=lime1 -mreference-types -msimd128"}' \
  'CONF_GCC_LINKER_OPTS_STAGE2=${CONF_GCC_LINKER_OPTS_STAGE2:-"-Wl,--error-limit=0,--keep-section=ghc_wasm_jsffi,--keep-section=target_features,--stack-first,--strip-debug "}' \
  'CONF_CC_OPTS_STAGE1=${CONF_CC_OPTS_STAGE1:-"-Wno-error=int-conversion -O3 -mcpu=lime1 -mreference-types -msimd128"}' \
  'CONF_CXX_OPTS_STAGE1=${CONF_CXX_OPTS_STAGE1:-"-fno-exceptions -Wno-error=int-conversion -O3 -mcpu=lime1 -mreference-types -msimd128"}' \
  'CONF_GCC_LINKER_OPTS_STAGE1=${CONF_GCC_LINKER_OPTS_STAGE1:-"-Wl,--error-limit=0,--keep-section=ghc_wasm_jsffi,--keep-section=target_features,--stack-first,--strip-debug "}' \
  "CONFIGURE_ARGS=\"--host=$HOST --target=wasm32-wasi --with-intree-gmp --with-system-libffi\"" \
  'CROSS_EMULATOR=${CROSS_EMULATOR:-"'"$PREFIX/wasm-run/bin/wasm-run.mjs"'"}' \
  'NODE_PATH=${NODE_PATH:-"'"$PREFIX/nodejs/lib/node_modules"'"}'
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
if [[ -z "${UPSTREAM_GHC_PIPELINE_ID:-}" ]]; then
  GHC_BINDIST="$(jq -r ".\"$GHC\".url" "$REPO"/autogen.json)"
else
  UPSTREAM_GHC_JOB_ID=$(curl -f -L --retry 5 https://gitlab.haskell.org/api/v4/projects/$UPSTREAM_GHC_PROJECT_ID/pipelines/$UPSTREAM_GHC_PIPELINE_ID/jobs?per_page=100 | jq -r ".[] | select(.name == \"$UPSTREAM_GHC_JOB_NAME\") | .id")
  GHC_BINDIST=https://gitlab.haskell.org/api/v4/projects/$UPSTREAM_GHC_PROJECT_ID/jobs/$UPSTREAM_GHC_JOB_ID/artifacts/ghc-$UPSTREAM_GHC_JOB_NAME.tar.xz
fi
echo "Installing wasm32-wasi-ghc from $GHC_BINDIST"
curl -f -L --retry 5 "$GHC_BINDIST" -o wasm32-wasi-ghc.tar.xz
tar xJf wasm32-wasi-ghc.tar.xz -C ghc --no-same-owner --strip-components=1
pushd ghc
sh -c ". $PREFIX/env && ./configure \$CONFIGURE_ARGS --prefix=$PREFIX/wasm32-wasi-ghc && RelocatableBuild=YES exec make install"
if [[ "$FLAVOUR" != 9.6 ]] && [[ "$FLAVOUR" != 9.8 ]]; then
  if [[ $SED_IS_GNU == "1" ]]; then
    grep -lrIF "$PREFIX" "$PREFIX/wasm32-wasi-ghc" | xargs sed -i "s@$PREFIX@\$topdir/../..@g"
  else
    grep -lrIF "$PREFIX" "$PREFIX/wasm32-wasi-ghc" | xargs sed -i "" "s@$PREFIX@\$topdir/../..@g"
  fi
  "$PREFIX/wasm32-wasi-ghc/bin/wasm32-wasi-ghc-pkg" recache
fi
popd

mkdir -p "$PREFIX/cabal/bin"
curl -f -L --retry 5 "$(jq -r ".\"$CABAL\".url" "$REPO"/autogen.json)" -o cabal.tar.xz
tar xJf cabal.tar.xz --no-same-owner -C "$PREFIX/cabal/bin" 'cabal'

mkdir -p "$PREFIX/wasm32-wasi-cabal/bin"
echo "#!/bin/sh" >> "$PREFIX/wasm32-wasi-cabal/bin/wasm32-wasi-cabal"
echo 'PREFIX=$(realpath "$(dirname "$0")"/../..)' >> "$PREFIX/wasm32-wasi-cabal/bin/wasm32-wasi-cabal"
if [[ "$FLAVOUR" != 9.6 ]] && [[ "$FLAVOUR" != 9.8 ]]; then
  echo \
    'CABAL_DIR=$PREFIX/.cabal' \
    'exec' \
    '$PREFIX/cabal/bin/cabal' \
    '--with-compiler=$PREFIX/wasm32-wasi-ghc/bin/wasm32-wasi-ghc' \
    '--with-hc-pkg=$PREFIX/wasm32-wasi-ghc/bin/wasm32-wasi-ghc-pkg' \
    '--with-hsc2hs=$PREFIX/wasm32-wasi-ghc/bin/wasm32-wasi-hsc2hs' \
    '--with-haddock=$PREFIX/wasm32-wasi-ghc/bin/wasm32-wasi-haddock' \
    '${1+"$@"}' >> "$PREFIX/wasm32-wasi-cabal/bin/wasm32-wasi-cabal"
else
  echo \
    'CABAL_DIR=$PREFIX/.cabal' \
    'exec' \
    '$PREFIX/cabal/bin/cabal' \
    '--with-compiler=$PREFIX/wasm32-wasi-ghc/bin/wasm32-wasi-ghc' \
    '--with-hc-pkg=$PREFIX/wasm32-wasi-ghc/bin/wasm32-wasi-ghc-pkg' \
    '--with-hsc2hs=$PREFIX/wasm32-wasi-ghc/bin/wasm32-wasi-hsc2hs' \
    '${1+"$@"}' >> "$PREFIX/wasm32-wasi-cabal/bin/wasm32-wasi-cabal"
fi
chmod 755 "$PREFIX/wasm32-wasi-cabal/bin/wasm32-wasi-cabal"

mkdir "$PREFIX/.cabal"
if [[ "$FLAVOUR" != 9.6 ]] && [[ "$FLAVOUR" != 9.8 ]] && [[ "$FLAVOUR" != 9.10 ]] && [[ "$FLAVOUR" != 9.12 ]] && [[ "$FLAVOUR" != 9.14 ]]; then
  cp "$REPO/cabal.head.config" "$PREFIX/.cabal/config"
elif [[ "$FLAVOUR" == 9.10 ]] || [[ "$FLAVOUR" == 9.12 ]] || [[ "$FLAVOUR" == 9.14 ]]; then
  cp "$REPO/cabal.th.config" "$PREFIX/.cabal/config"
else
  cp "$REPO/cabal.legacy.config" "$PREFIX/.cabal/config"
fi
"$PREFIX/wasm32-wasi-cabal/bin/wasm32-wasi-cabal" update

popd

echo "Everything set up in $PREFIX."
echo "Run 'source $PREFIX/env' to add tools to your PATH."
