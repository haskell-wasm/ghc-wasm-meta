#!/usr/bin/env bash

set -euo pipefail

export BIGNUM_BACKEND=gmp
export BIN_DIST_NAME=ghc-$(uname -m)-linux-alpine3_22-wasm-cross_wasm32-wasi-quick+host_fully_static+text_simdutf
export BUILD_FLAVOUR=quick+host_fully_static+text_simdutf
if [[ "$(uname -m)" == "x86_64" ]]; then
  export CONFIGURE_ARGS="--with-intree-gmp --with-system-libffi --enable-strict-ghc-toolchain-check"
else
  export CONFIGURE_ARGS="--host=aarch64-alpine-linux --target=wasm32-wasi --with-intree-gmp --with-system-libffi"
fi
export CROSS_TARGET=wasm32-wasi
export FIREFOX_LAUNCH_OPTS='{"browser":"firefox","executablePath":"/usr/bin/firefox"}'
export HADRIAN_ARGS="--docs=none"
export RUNTEST_ARGS=""
export TEST="browser001-firefox"
export TEST_ENV=$(uname -m)-linux-alpine3_22-wasm-cross_wasm32-wasi-quick+host_fully_static+text_simdutf
export XZ_OPT="-0"

pushd "$(mktemp -d)"

git clone --ref-format=reftable --depth=1 --recurse-submodules --shallow-submodules --jobs=32 https://gitlab.haskell.org/ghc/ghc.git .
echo "#!/bin/sh" > .gitlab/test-metrics.sh

.gitlab/ci.sh setup
.gitlab/ci.sh configure
.gitlab/ci.sh build_hadrian
.gitlab/ci.sh test_hadrian

popd
