#!/usr/bin/env bash

set -euo pipefail

rm -f package-lock.json
npm update --save
rm -rf node_modules
git add package.json package-lock.json
nix-update --flake npm-deps --no-src --version skip
git add pkgs/npm-deps.nix
