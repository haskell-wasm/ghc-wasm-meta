#!/usr/bin/env -S deno run --allow-net --allow-read --allow-run --allow-write

async function fetchJSON(url) {
  const r = await fetch(url);
  if (!r.ok) throw new Error(await r.text());
  return r.json();
}

const _stableBindists = fetchJSON(
  "https://raw.githubusercontent.com/haskell-wasm/ghc-wasm-bindists/main/meta.json"
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

async function fetchurl(url) {
  const cmd = new Deno.Command("nix", {
    args: ["store", "prefetch-file", "--hash-type", "sha512", "--json", url],
    stdin: "null",
    stderr: "null",
  });
  const { stdout } = await cmd.output();
  return {
    url,
    hash: JSON.parse(new TextDecoder("utf-8", { fatal: true }).decode(stdout))
      .hash,
  };
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
const _wasm32_wasi_ghc_9_12 = fetchStableBindist("wasm32-wasi-ghc-9.12");
const _wasm32_wasi_ghc_gmp_aarch64_darwin = fetchStableBindist(
  "wasm32-wasi-ghc-gmp-aarch64-darwin"
);
const _wasm32_wasi_ghc_gmp_aarch64_darwin_9_10 = fetchStableBindist(
  "wasm32-wasi-ghc-gmp-aarch64-darwin-9.10"
);
const _wasm32_wasi_ghc_gmp_aarch64_darwin_9_12 = fetchStableBindist(
  "wasm32-wasi-ghc-gmp-aarch64-darwin-9.12"
);
const _wasm32_wasi_ghc_gmp_x86_64_darwin = fetchStableBindist(
  "wasm32-wasi-ghc-gmp-x86_64-darwin"
);
const _wasm32_wasi_ghc_gmp_aarch64_linux = fetchStableBindist(
  "wasm32-wasi-ghc-gmp-aarch64-linux"
);
const _wasi_sdk = fetchStableBindist("wasi-sdk");
const _wasi_sdk_aarch64_darwin = fetchStableBindist("wasi-sdk-aarch64-darwin");
const _wasi_sdk_x86_64_darwin = fetchStableBindist("wasi-sdk-x86_64-darwin");
const _wasi_sdk_aarch64_linux = fetchStableBindist("wasi-sdk-aarch64-linux");
const _libffi_wasm = fetchStableBindist("libffi-wasm");
const _nodejs = fetchGitHubLatestRelease(
  "haskell-wasm",
  "node-static",
  "linux-x64-static.tar.xz"
);
const _nodejs_aarch64_linux = fetchGitHubLatestRelease(
  "haskell-wasm",
  "node-static",
  "linux-arm64-static.tar.xz"
);
const _nodejs_aarch64_darwin = fetchGitHubLatestRelease(
  "haskell-wasm",
  "node-static",
  "darwin-arm64.tar.xz"
);
const _nodejs_x86_64_darwin = fetchGitHubLatestRelease(
  "haskell-wasm",
  "node-static",
  "darwin-x64.tar.xz"
);
const _binaryen = fetchGitHubLatestRelease(
  "haskell-wasm",
  "binaryen",
  "x86_64-linux-static.tar.gz"
);
const _binaryen_aarch64_linux = fetchGitHubLatestRelease(
  "haskell-wasm",
  "binaryen",
  "aarch64-linux-static.tar.gz"
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
const _wasmtime = fetchGitHubLatestRelease(
  "haskell-wasm",
  "wasm-tools-static",
  "x86_64-linux.tar.zst"
);
const _wasmtime_aarch64_linux = fetchGitHubLatestRelease(
  "haskell-wasm",
  "wasm-tools-static",
  "aarch64-linux.tar.zst"
);
const _wasmtime_aarch64_darwin = fetchGitHubLatestRelease(
  "haskell-wasm",
  "wasm-tools-static",
  "darwin-aarch64.tar.zst"
);
const _wasmtime_x86_64_darwin = fetchGitHubLatestRelease(
  "haskell-wasm",
  "wasm-tools-static",
  "darwin-x86_64.tar.zst"
);
const _cabal = fetchurl(
  "https://downloads.haskell.org/cabal/cabal-install-3.14.1.1/cabal-install-3.14.1.1-x86_64-linux-alpine3_18.tar.xz"
);
const _cabal_aarch64_linux = fetchurl(
  "https://downloads.haskell.org/cabal/cabal-install-3.14.1.1/cabal-install-3.14.1.1-aarch64-linux-alpine3_18.tar.xz"
);
const _cabal_aarch64_darwin = fetchurl(
  "https://downloads.haskell.org/cabal/cabal-install-3.14.1.1/cabal-install-3.14.1.1-aarch64-darwin.tar.xz"
);
const _cabal_x86_64_darwin = fetchurl(
  "https://downloads.haskell.org/cabal/cabal-install-3.14.1.1/cabal-install-3.14.1.1-x86_64-darwin.tar.xz"
);

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
      "wasm32-wasi-ghc-9.12": await _wasm32_wasi_ghc_9_12,
      "wasm32-wasi-ghc-gmp-aarch64-darwin":
        await _wasm32_wasi_ghc_gmp_aarch64_darwin,
      "wasm32-wasi-ghc-gmp-aarch64-darwin-9.10":
        await _wasm32_wasi_ghc_gmp_aarch64_darwin_9_10,
      "wasm32-wasi-ghc-gmp-aarch64-darwin-9.12":
        await _wasm32_wasi_ghc_gmp_aarch64_darwin_9_12,
      "wasm32-wasi-ghc-gmp-x86_64-darwin":
        await _wasm32_wasi_ghc_gmp_x86_64_darwin,
      "wasm32-wasi-ghc-gmp-aarch64-linux":
        await _wasm32_wasi_ghc_gmp_aarch64_linux,
      "wasi-sdk": await _wasi_sdk,
      "wasi-sdk-aarch64-darwin": await _wasi_sdk_aarch64_darwin,
      "wasi-sdk-x86_64-darwin": await _wasi_sdk_x86_64_darwin,
      "wasi-sdk-aarch64-linux": await _wasi_sdk_aarch64_linux,
      "libffi-wasm": await _libffi_wasm,
      nodejs: await _nodejs,
      nodejs_aarch64_linux: await _nodejs_aarch64_linux,
      nodejs_aarch64_darwin: await _nodejs_aarch64_darwin,
      nodejs_x86_64_darwin: await _nodejs_x86_64_darwin,
      binaryen: await _binaryen,
      binaryen_aarch64_linux: await _binaryen_aarch64_linux,
      binaryen_aarch64_darwin: await _binaryen_aarch64_darwin,
      binaryen_x86_64_darwin: await _binaryen_x86_64_darwin,
      wasmtime: await _wasmtime,
      wasmtime_aarch64_linux: await _wasmtime_aarch64_linux,
      wasmtime_aarch64_darwin: await _wasmtime_aarch64_darwin,
      wasmtime_x86_64_darwin: await _wasmtime_x86_64_darwin,
      cabal: await _cabal,
      cabal_aarch64_linux: await _cabal_aarch64_linux,
      cabal_aarch64_darwin: await _cabal_aarch64_darwin,
      cabal_x86_64_darwin: await _cabal_x86_64_darwin,
    },
    null,
    2
  )
);
