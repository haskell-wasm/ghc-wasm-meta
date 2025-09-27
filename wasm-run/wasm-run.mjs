#!/usr/bin/env -S node --disable-warning=ExperimentalWarning --max-old-space-size=65536 --wasm-lazy-validation

import fs from "node:fs";
import stream from "node:stream";
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

const mod = await WebAssembly.compileStreaming(
  new Response(stream.Readable.toWeb(fs.createReadStream(argv[0])), {
    headers: { "Content-Type": "application/wasm" },
  })
);

const import_obj = {
  wasi_snapshot_preview1: wasi.wasiImport,
};

for (const { module, name, kind } of WebAssembly.Module.imports(mod)) {
  if (import_obj[module] && import_obj[module][name]) {
    continue;
  }

  if (kind === "function") {
    if (!import_obj[module]) {
      import_obj[module] = {};
    }

    import_obj[module][name] = (...args) => {
      throw new WebAssembly.RuntimeError(
        `stub import ${module} ${name} ${args}`
      );
    };
  }
}

const instance = await WebAssembly.instantiate(mod, import_obj);

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
