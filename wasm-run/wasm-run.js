#!/usr/bin/env -S deno run --allow-read --allow-write

import WasiContext from "https://deno.land/std@0.206.0/wasi/snapshot_preview1.ts";

function parseArgv(args) {
  const i = args.indexOf("-0");
  return i === -1 ? args : args.slice(i + 2);
}

const argv = parseArgv(Deno.args);

const context = new WasiContext({
  args: argv,
  env: { PATH: "", PWD: Deno.cwd() },
  preopens: { "/": "/" },
});

const instance = (
  await WebAssembly.instantiate(await Deno.readFile(argv[0]), {
    wasi_snapshot_preview1: context.exports,
  })
).instance;

try {
  let ec = context.start(instance);
  if (ec === null) {
    ec = 0;
  }
  if (ec >= 126) {
    ec = 1;
  }
  Deno.exit(ec);
} catch (err) {
  if (!(err instanceof WebAssembly.RuntimeError)) {
    throw err;
  }
  console.error(err.stack);
  Deno.exit(134);
}
