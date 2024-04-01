#!/usr/bin/env -S deno run --allow-net --allow-read --allow-run --allow-write

async function fetchJSON(url) {
  const r = await fetch(url);
  if (!r.ok) throw new Error(await r.text());
  return r.json();
}

const _stableBindists = fetchJSON(
  "https://raw.githubusercontent.com/amesgen/ghc-wasm-bindists/main/meta.json"
);

async function fetchStableBindist(id) {
  const dist = (await _stableBindists)[id];
  return { url: dist.mirrorUrl, hash: dist.sriHash };
}

async function fetchGitHubLatestReleaseURL(owner, repo, suffix) {
  return (
    await fetchJSON(
      `https://api.github.com/repos/${owner}/${repo}/releases/latest`
    )
  ).assets.find((e) => e.name.endsWith(suffix)).browser_download_url;
}

function parseActualHash(msg) {
  return Array.from(msg.matchAll(/sha256:[0-9a-z]+/g))
    .at(-1)[0]
    .split("sha256:")[1];
}

async function fetchHash(fetcher, fetcher_opts) {
  const proc = Deno.run({
    cmd: [
      "nix",
      "eval",
      "--expr",
      `${fetcher}(builtins.fromJSON(${JSON.stringify(
        JSON.stringify(fetcher_opts)
      )}))`,
    ],
    stdin: "null",
    stdout: "null",
    stderr: "piped",
  });
  const msg = new TextDecoder().decode(await proc.stderrOutput());
  const hash = parseActualHash(msg);
  await proc.status();
  return hash;
}

async function fetchGitHubLatestRelease(fetcher, owner, repo, suffix) {
  const url = await fetchGitHubLatestReleaseURL(owner, repo, suffix);
  const sha256 = await fetchHash(fetcher, { url, sha256: "" });
  return { url, sha256 };
}

async function fetchTarball(url) {
  const sha256 = await fetchHash("builtins.fetchTarball", { url, sha256: "" });
  return { url, sha256 };
}

async function fetchurl(url) {
  const sha256 = await fetchHash("builtins.fetchurl", { url, sha256: "" });
  return { url, sha256 };
}

const _wasm32_wasi_ghc_gmp = fetchStableBindist("wasm32-wasi-ghc-gmp");
const _wasm32_wasi_ghc_native = fetchStableBindist("wasm32-wasi-ghc-native");
const _wasm32_wasi_ghc_unreg = fetchStableBindist("wasm32-wasi-ghc-unreg");
const _wasm32_wasi_ghc_9_6 = fetchStableBindist("wasm32-wasi-ghc-9.6");
const _wasm32_wasi_ghc_9_8 = fetchStableBindist("wasm32-wasi-ghc-9.8");
const _wasm32_wasi_ghc_9_10 = fetchStableBindist("wasm32-wasi-ghc-9.10");
const _wasi_sdk = fetchStableBindist("wasi-sdk");
const _wasi_sdk_darwin = fetchStableBindist("wasi-sdk-darwin");
const _wasi_sdk_aarch64_linux = fetchStableBindist("wasi-sdk-aarch64-linux");
const _libffi_wasm = fetchStableBindist("libffi-wasm");
const _deno = fetchGitHubLatestRelease(
  "builtins.fetchTarball",
  "denoland",
  "deno",
  "x86_64-unknown-linux-gnu.zip"
);
const _nodejs = fetchGitHubLatestRelease(
  "builtins.fetchTarball",
  "type-dance",
  "node-static",
  "linux-x64-static.tar.xz"
);
const _bun = fetchGitHubLatestRelease(
  "builtins.fetchTarball",
  "oven-sh",
  "bun",
  "linux-x64.zip"
);
const _binaryen = fetchGitHubLatestRelease(
  "builtins.fetchTarball",
  "type-dance",
  "binaryen",
  "x86_64-linux-musl.tar.zst"
);
const _wabt = fetchGitHubLatestRelease(
  "builtins.fetchTarball",
  "WebAssembly",
  "wabt",
  "ubuntu.tar.gz"
);
const _wasmtime = fetchGitHubLatestRelease(
  "builtins.fetchTarball",
  "type-dance",
  "wasm-tools-static",
  "x86_64-linux.tar.zst"
);
const _wasmtime_aarch64_linux = fetchGitHubLatestRelease(
  "builtins.fetchTarball",
  "type-dance",
  "wasm-tools-static",
  "aarch64-linux.tar.zst"
);
const _wasmtime_aarch64_darwin = fetchGitHubLatestRelease(
  "builtins.fetchTarball",
  "type-dance",
  "wasm-tools-static",
  "darwin-aarch64.tar.zst"
);
const _wasmtime_x86_64_darwin = fetchGitHubLatestRelease(
  "builtins.fetchTarball",
  "type-dance",
  "wasm-tools-static",
  "darwin-x86_64.tar.zst"
);
const _wasmedge = fetchGitHubLatestRelease(
  "builtins.fetchTarball",
  "WasmEdge",
  "WasmEdge",
  "ubuntu20.04_x86_64.tar.gz"
);
const _wazero = fetchGitHubLatestRelease(
  "builtins.fetchTarball",
  "tetratelabs",
  "wazero",
  "linux_amd64.tar.gz"
);
const _cabal = fetchurl(
  "https://downloads.haskell.org/cabal/cabal-install-3.10.3.0/cabal-install-3.10.3.0-x86_64-linux-alpine3_12.tar.xz"
);
const _proot = fetchStableBindist("proot");

await Deno.writeTextFile(
  "autogen.json",
  JSON.stringify(
    {
      "wasm32-wasi-ghc-gmp": await _wasm32_wasi_ghc_gmp,
      "wasm32-wasi-ghc-native": await _wasm32_wasi_ghc_native,
      "wasm32-wasi-ghc-unreg": await _wasm32_wasi_ghc_unreg,
      "wasm32-wasi-ghc-9.6": await _wasm32_wasi_ghc_9_6,
      "wasm32-wasi-ghc-9.8": await _wasm32_wasi_ghc_9_8,
      "wasm32-wasi-ghc-9.10": await _wasm32_wasi_ghc_9_10,
      "wasi-sdk": await _wasi_sdk,
      "wasi-sdk_darwin": await _wasi_sdk_darwin,
      "wasi-sdk_aarch64_linux": await _wasi_sdk_aarch64_linux,
      "libffi-wasm": await _libffi_wasm,
      deno: await _deno,
      nodejs: await _nodejs,
      bun: await _bun,
      binaryen: await _binaryen,
      wabt: await _wabt,
      wasmtime: await _wasmtime,
      wasmtime_aarch64_linux: await _wasmtime_aarch64_linux,
      wasmtime_aarch64_darwin: await _wasmtime_aarch64_darwin,
      wasmtime_x86_64_darwin: await _wasmtime_x86_64_darwin,
      wasmedge: await _wasmedge,
      wazero: await _wazero,
      cabal: await _cabal,
      proot: await _proot,
    },
    null,
    2
  )
);
