#!/bin/sh

exec wasmtime run -C cache=n -C compiler=cranelift -C parallel-compilation=n --env PATH= --env PWD="$PWD" --dir /::/ -O opt-level=0 -- ${1+"$@"}
