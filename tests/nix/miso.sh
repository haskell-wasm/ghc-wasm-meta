#!/usr/bin/env bash

set -euo pipefail

pushd "$(mktemp -d)"
git clone --depth=1 https://github.com/dmjio/miso.git .
nix flake lock --allow-dirty-locks --override-input ghc-wasm-meta "git+file://$CI_PROJECT_DIR"
nix build -f . playwright-wasm
nix shell nixpkgs#procps --command ./result/bin/playwright
popd

miso_example() {
  pushd "$(mktemp -d)"
  git clone --depth=1 "$1" .
  nix flake lock --allow-dirty-locks --override-input miso/ghc-wasm-meta "git+file://$CI_PROJECT_DIR"
  nix develop .#wasm --command make
  if [[ -n "${2-}" ]]; then
    bash -c "$2"
  fi
  popd
}

miso_example https://github.com/haskell-miso/bun-wasm.git "nix run nixpkgs#bun -- install && nix run nixpkgs#bun -- test"
# miso_example https://github.com/haskell-miso/haskell-miso.org.git
# miso_example https://github.com/haskell-miso/miso-2048.git
# miso_example https://github.com/haskell-miso/miso-audio.git
# miso_example https://github.com/haskell-miso/miso-fetch.git
# miso_example https://github.com/haskell-miso/miso-flatris.git
# https://github.com/digital-asset/ghc-lib/issues/614
# miso_example https://github.com/haskell-miso/miso-from-html.git
# miso_example https://github.com/haskell-miso/miso-invaders.git
# miso_example https://github.com/haskell-miso/miso-minesweeper.git
# miso_example https://github.com/haskell-miso/miso-plane.git
# https://github.com/haskell-miso/miso-pubsub/issues/1
# miso_example https://github.com/haskell-miso/miso-pubsub.git
# miso_example https://github.com/haskell-miso/miso-reactive.git
# miso_example https://github.com/haskell-miso/miso-router.git
miso_example https://github.com/haskell-miso/miso-sampler.git
# miso_example https://github.com/haskell-miso/miso-snake.git
miso_example https://github.com/haskell-miso/miso-todomvc.git
miso_example https://github.com/haskell-miso/miso-video.git
miso_example https://github.com/haskell-miso/miso-websocket.git
# miso_example https://github.com/haskell-miso/three-miso.git
