#!/bin/sh

set -eu

cd "$(mktemp -d)"

curl -f -L --retry 5 https://gitlab.haskell.org/ghc/ghc-wasm-meta/-/archive/master/ghc-wasm-meta-master.tar.gz | tar xz --strip-components=1

exec ./setup.sh
