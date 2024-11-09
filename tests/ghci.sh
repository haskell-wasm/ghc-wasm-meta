#!/usr/bin/env bash

set -euo pipefail

echo -e 'foreign import javascript "Promise.resolve(114514)" x :: IO Int\nx\n' | wasm32-wasi-ghc --interactive -package ghc -package Cabal
