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
  registry.gitlab.haskell.org/ghc/ci-images/x86_64-linux-ubuntu24_04:59da90988f9f3caa36572bf47d5f78704a969dea \
  bash -c \
  "apt update && apt install -y bash-completion nano zstd && cp /etc/skel/{.bash_logout,.bashrc,.profile} /root && PREFIX=/tmp/.ghc-wasm ./setup.sh && . /tmp/.ghc-wasm/env && exec bash -i"
