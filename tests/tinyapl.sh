#!/usr/bin/env bash

set -euo pipefail

pushd "$(mktemp -d)"
curl -f -L https://github.com/RubenVerg/TinyAPL/archive/refs/heads/beta.tar.gz | tar xz --strip-components=1
cp $CI_PROJECT_DIR/cabal.project.local .
./app/build.sh
popd
