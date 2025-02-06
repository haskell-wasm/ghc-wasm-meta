#!/bin/sh

exec podman run -it --rm \
  --env CI_PROJECT_DIR=/workspace \
  --env FLAVOUR="$1" \
  --user root \
  --init \
  --tmpfs /tmp:exec \
  --network host \
  --volume "$PWD":/workspace \
  --workdir /workspace \
  registry.gitlab.haskell.org/ghc/ci-images/x86_64-linux-ubuntu24_04:66be29543a78357dfcdd90c112989d006dbed0ba \
  bash -c \
  "apt update && apt install -y bash-completion nano zstd && cp /etc/skel/{.bash_logout,.bashrc,.profile} /root && PREFIX=/tmp/.ghc-wasm ./setup.sh && . /tmp/.ghc-wasm/env && exec bash -i"
