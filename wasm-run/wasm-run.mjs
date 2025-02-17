#!/usr/bin/env -S node --disable-warning=ExperimentalWarning --max-old-space-size=65536 --no-turbo-fast-api-calls --wasm-lazy-validation

import fs from "node:fs/promises";
import { WASI } from "node:wasi";

function parseArgv(args) {
  const i = args.indexOf("-0");
  return i === -1 ? args : args.slice(i + 2);
}

const argv = parseArgv(process.argv.slice(2));

const wasi = new WASI({
  version: "preview1",
  args: argv,
  env: { PATH: "", PWD: process.cwd() },
  preopens: { "/": "/" },
});

const instance = (
  await WebAssembly.instantiate(await fs.readFile(argv[0]), {
    wasi_snapshot_preview1: wasi.wasiImport,
  })
).instance;

try {
  let ec = wasi.start(instance);
  // wasmtime reports "exit with invalid exit status outside of [0..126)"
  if (ec >= 126) {
    ec = 1;
  }
  process.exit(ec);
} catch (err) {
  if (!(err instanceof WebAssembly.RuntimeError)) {
    throw err;
  }
  console.error(err.stack);
  // wasmtime exits with 128+SIGABRT
  process.exit(134);
}
