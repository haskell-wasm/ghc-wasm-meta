#!/usr/bin/env -S deno run --allow-net --allow-read --allow-run --allow-write

async function fetchJSON(url) {
  const r = await fetch(url);
  if (!r.ok) throw new Error(await r.text());
  return r.json();
}

const _stableBindists = fetchJSON(
  "https://raw.githubusercontent.com/tweag/ghc-wasm-bindists/main/meta.json"
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

async function fetchHash(fetcher, fetcher_opts) {
  const cmd = new Deno.Command("nix-prefetch", {
    args: [
      fetcher,
      ...Object.entries(fetcher_opts).flatMap(([k, v]) => [`--${k}`, v]),
    ],
    stdin: "null",
    stderr: "null",
  });
  const { stdout } = await cmd.output();
  return new TextDecoder("utf-8", { fatal: true }).decode(stdout).trim();
}

async function fetchurl(url) {
  const hash = await fetchHash("fetchurl", { url, "hash-algo": "sha512" });
  return { url, hash };
}

async function fetchGitHubLatestRelease(owner, repo, suffix) {
  const url = await fetchGitHubLatestReleaseURL(owner, repo, suffix);
  return fetchurl(url);
}

const _wasm32_wasi_ghc_gmp = fetchStableBindist("wasm32-wasi-ghc-gmp");
const _wasm32_wasi_ghc_native = fetchStableBindist("wasm32-wasi-ghc-native");
const _wasm32_wasi_ghc_unreg = fetchStableBindist("wasm32-wasi-ghc-unreg");
const _wasm32_wasi_ghc_9_6 = fetchStableBindist("wasm32-wasi-ghc-9.6");
const _wasm32_wasi_ghc_9_8 = fetchStableBindist("wasm32-wasi-ghc-9.8");
const _wasm32_wasi_ghc_9_10 = fetchStableBindist("wasm32-wasi-ghc-9.10");
const _wasm32_wasi_ghc_gmp_aarch64_darwin = fetchStableBindist(
  "wasm32-wasi-ghc-gmp-aarch64-darwin"
);
const _wasm32_wasi_ghc_gmp_x86_64_darwin = fetchStableBindist(
  "wasm32-wasi-ghc-gmp-x86_64-darwin"
);
const _wasm32_wasi_ghc_gmp_aarch64_linux = fetchStableBindist(
  "wasm32-wasi-ghc-gmp-aarch64-linux"
);
const _wasi_sdk = fetchStableBindist("wasi-sdk");
const _wasi_sdk_darwin = fetchStableBindist("wasi-sdk-darwin");
const _wasi_sdk_aarch64_linux = fetchStableBindist("wasi-sdk-aarch64-linux");
const _libffi_wasm = fetchStableBindist("libffi-wasm");
const _deno = fetchGitHubLatestRelease(
  "denoland",
  "deno",
  "x86_64-unknown-linux-gnu.zip"
);
const _deno_aarch64_linux = fetchGitHubLatestRelease(
  "denoland",
  "deno",
  "aarch64-unknown-linux-gnu.zip"
);
const _deno_aarch64_darwin = fetchGitHubLatestRelease(
  "denoland",
  "deno",
  "aarch64-apple-darwin.zip"
);
const _deno_x86_64_darwin = fetchGitHubLatestRelease(
  "denoland",
  "deno",
  "x86_64-apple-darwin.zip"
);
const _nodejs = fetchGitHubLatestRelease(
  "TerrorJack",
  "node-static",
  "linux-x64-static.tar.xz"
);
const _nodejs_aarch64_linux = fetchurl(
  "https://nodejs.org/dist/v22.2.0/node-v22.2.0-linux-arm64.tar.xz"
);
const _nodejs_aarch64_darwin = fetchurl(
  "https://nodejs.org/dist/v22.2.0/node-v22.2.0-darwin-arm64.tar.xz"
);
const _nodejs_x86_64_darwin = fetchurl(
  "https://nodejs.org/dist/v22.2.0/node-v22.2.0-darwin-x64.tar.xz"
);
const _bun = fetchGitHubLatestRelease("oven-sh", "bun", "linux-x64.zip");
const _bun_aarch64_linux = fetchGitHubLatestRelease(
  "oven-sh",
  "bun",
  "linux-aarch64.zip"
);
const _bun_aarch64_darwin = fetchGitHubLatestRelease(
  "oven-sh",
  "bun",
  "darwin-aarch64.zip"
);
const _bun_x86_64_darwin = fetchGitHubLatestRelease(
  "oven-sh",
  "bun",
  "darwin-x64.zip"
);
const _binaryen = fetchGitHubLatestRelease(
  "type-dance",
  "binaryen",
  "x86_64-linux-musl.tar.gz"
);
const _binaryen_aarch64_linux = fetchGitHubLatestRelease(
  "WebAssembly",
  "binaryen",
  "aarch64-linux.tar.gz"
);
const _binaryen_aarch64_darwin = fetchGitHubLatestRelease(
  "WebAssembly",
  "binaryen",
  "arm64-macos.tar.gz"
);
const _binaryen_x86_64_darwin = fetchGitHubLatestRelease(
  "WebAssembly",
  "binaryen",
  "x86_64-macos.tar.gz"
);
const _wabt = fetchGitHubLatestRelease(
  "WebAssembly",
  "wabt",
  "ubuntu-20.04.tar.gz"
);
const _wasmtime = fetchGitHubLatestRelease(
  "TerrorJack",
  "wasm-tools-static",
  "x86_64-linux.tar.zst"
);
const _wasmtime_aarch64_linux = fetchGitHubLatestRelease(
  "TerrorJack",
  "wasm-tools-static",
  "aarch64-linux.tar.zst"
);
const _wasmtime_aarch64_darwin = fetchGitHubLatestRelease(
  "TerrorJack",
  "wasm-tools-static",
  "darwin-aarch64.tar.zst"
);
const _wasmtime_x86_64_darwin = fetchGitHubLatestRelease(
  "TerrorJack",
  "wasm-tools-static",
  "darwin-x86_64.tar.zst"
);
const _wasmedge = fetchGitHubLatestRelease(
  "WasmEdge",
  "WasmEdge",
  "ubuntu20.04_x86_64.tar.gz"
);
const _wasmedge_aarch64_linux = fetchGitHubLatestRelease(
  "WasmEdge",
  "WasmEdge",
  "ubuntu20.04_aarch64.tar.gz"
);
const _wasmedge_aarch64_darwin = fetchGitHubLatestRelease(
  "WasmEdge",
  "WasmEdge",
  "darwin_arm64.tar.gz"
);
const _wasmedge_x86_64_darwin = fetchGitHubLatestRelease(
  "WasmEdge",
  "WasmEdge",
  "darwin_x86_64.tar.gz"
);
const _wazero = fetchGitHubLatestRelease(
  "tetratelabs",
  "wazero",
  "linux_amd64.tar.gz"
);
const _wazero_aarch64_linux = fetchGitHubLatestRelease(
  "tetratelabs",
  "wazero",
  "linux_arm64.tar.gz"
);
const _wazero_aarch64_darwin = fetchGitHubLatestRelease(
  "tetratelabs",
  "wazero",
  "darwin_arm64.tar.gz"
);
const _wazero_x86_64_darwin = fetchGitHubLatestRelease(
  "tetratelabs",
  "wazero",
  "darwin_amd64.tar.gz"
);
const _cabal = fetchurl(
  "https://downloads.haskell.org/ghcup/unofficial-bindists/cabal/3.12.1.0/cabal-install-3.12.1.0-x86_64-linux-unknown.tar.xz"
);
const _cabal_aarch64_linux = fetchurl(
  "https://downloads.haskell.org/ghcup/unofficial-bindists/cabal/3.12.1.0/cabal-install-3.12.1.0-aarch64-linux-deb10.tar.xz"
);
const _cabal_aarch64_darwin = fetchurl(
  "https://downloads.haskell.org/ghcup/unofficial-bindists/cabal/3.12.1.0/cabal-install-3.12.1.0-aarch64-apple-darwin.tar.xz"
);
const _cabal_x86_64_darwin = fetchurl(
  "https://downloads.haskell.org/ghcup/unofficial-bindists/cabal/3.12.1.0/cabal-install-3.12.1.0-x86_64-apple-darwin.tar.xz"
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
      "wasm32-wasi-ghc-gmp-aarch64-darwin":
        await _wasm32_wasi_ghc_gmp_aarch64_darwin,
      "wasm32-wasi-ghc-gmp-x86_64-darwin":
        await _wasm32_wasi_ghc_gmp_x86_64_darwin,
      "wasm32-wasi-ghc-gmp-aarch64-linux":
        await _wasm32_wasi_ghc_gmp_aarch64_linux,
      "wasi-sdk": await _wasi_sdk,
      "wasi-sdk_darwin": await _wasi_sdk_darwin,
      "wasi-sdk_aarch64_linux": await _wasi_sdk_aarch64_linux,
      "libffi-wasm": await _libffi_wasm,
      deno: await _deno,
      deno_aarch64_linux: await _deno_aarch64_linux,
      deno_aarch64_darwin: await _deno_aarch64_darwin,
      deno_x86_64_darwin: await _deno_x86_64_darwin,
      nodejs: await _nodejs,
      nodejs_aarch64_linux: await _nodejs_aarch64_linux,
      nodejs_aarch64_darwin: await _nodejs_aarch64_darwin,
      nodejs_x86_64_darwin: await _nodejs_x86_64_darwin,
      bun: await _bun,
      bun_aarch64_linux: await _bun_aarch64_linux,
      bun_aarch64_darwin: await _bun_aarch64_darwin,
      bun_x86_64_darwin: await _bun_x86_64_darwin,
      binaryen: await _binaryen,
      binaryen_aarch64_linux: await _binaryen_aarch64_linux,
      binaryen_aarch64_darwin: await _binaryen_aarch64_darwin,
      binaryen_x86_64_darwin: await _binaryen_x86_64_darwin,
      wabt: await _wabt,
      wasmtime: await _wasmtime,
      wasmtime_aarch64_linux: await _wasmtime_aarch64_linux,
      wasmtime_aarch64_darwin: await _wasmtime_aarch64_darwin,
      wasmtime_x86_64_darwin: await _wasmtime_x86_64_darwin,
      wasmedge: await _wasmedge,
      wasmedge_aarch64_linux: await _wasmedge_aarch64_linux,
      wasmedge_aarch64_darwin: await _wasmedge_aarch64_darwin,
      wasmedge_x86_64_darwin: await _wasmedge_x86_64_darwin,
      wazero: await _wazero,
      wazero_aarch64_linux: await _wazero_aarch64_linux,
      wazero_aarch64_darwin: await _wazero_aarch64_darwin,
      wazero_x86_64_darwin: await _wazero_x86_64_darwin,
      cabal: await _cabal,
      cabal_aarch64_linux: await _cabal_aarch64_linux,
      cabal_aarch64_darwin: await _cabal_aarch64_darwin,
      cabal_x86_64_darwin: await _cabal_x86_64_darwin,
      proot: await _proot,
    },
    null,
    2
  )
);
