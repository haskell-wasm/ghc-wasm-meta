#!/bin/sh

exec glab ci run \
  --variables UPSTREAM_GHC_PIPELINE_ID:"$1" \
  --variables UPSTREAM_GHC_PROJECT_ID:1 \
  --variables UPSTREAM_GHC_FLAVOUR:gmp \
  --variables UPSTREAM_GHC_JOB_NAME:x86_64-linux-alpine3_23-wasm-cross_wasm32-wasi-release+host_fully_static+text_simdutf
