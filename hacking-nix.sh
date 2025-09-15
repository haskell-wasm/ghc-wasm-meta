#!/bin/sh

exec podman run -it --rm \
  --env CI_PROJECT_DIR=/workspace \
  --env CPUS=48 \
  --init \
  --volume "$PWD":/workspace \
  --workdir /workspace \
  nixos/nix \
  bash -c \
  'echo "accept-flake-config = true" >> /etc/nix/nix.conf && echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf && echo "cores = $CPUS" >> /etc/nix/nix.conf && echo "max-jobs = $CPUS" >> /etc/nix/nix.conf && echo "extra-substituters = https://cache.iog.io" >> /etc/nix/nix.conf && echo "extra-trusted-public-keys = hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ=" >> /etc/nix/nix.conf && exec bash -i'
