#!/bin/sh

exec podman run -it --rm \
  --env CI_PROJECT_DIR=/workspace \
  --env CPUS=48 \
  --env LANG=C.UTF-8 \
  --init \
  --volume "$PWD":/workspace \
  --workdir /workspace \
  nixos/nix \
  bash -c \
  'echo "accept-flake-config = true" >> /etc/nix/nix.conf && echo "compress-build-log = false" >> /etc/nix/nix.conf && echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf && echo "cores = $CPUS" >> /etc/nix/nix.conf && echo "max-jobs = $CPUS" >> /etc/nix/nix.conf && echo "download-buffer-size = 1073741824" >> /etc/nix/nix.conf && echo "extra-substituters = https://cache.iog.io https://nixcache.reflex-frp.org" >> /etc/nix/nix.conf && echo "extra-trusted-public-keys = hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ= ryantrinkle.com-1:JJiAKaRv9mWgpVAz8dwewnZe0AzzEAzPkagE9SP5NWI=" >> /etc/nix/nix.conf && echo "sandbox = true" >> /etc/nix/nix.conf && nix shell .#all_9_12 --command wasm32-wasi-cabal update --ignore-project && nix run nixpkgs#gnused -- -i -e "s/\$ncpus/$CPUS/" "$HOME/.ghc-wasm/.cabal/config" && exec bash -i'
