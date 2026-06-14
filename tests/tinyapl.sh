#!/usr/bin/env bash

set -euo pipefail

pushd "$(mktemp -d)"
git clone --depth=1 --recurse-submodules --shallow-submodules --branch=beta https://github.com/RubenVerg/TinyAPL.git .
cp $CI_PROJECT_DIR/cabal.project.local .
./app/build.sh
popd
