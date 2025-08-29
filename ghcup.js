#!/usr/bin/env -S deno run --allow-net --allow-read --allow-run --allow-write

import * as encoding from "jsr:@std/encoding";
import * as yaml from "jsr:@std/yaml";

async function fetchJSON(url) {
  const r = await fetch(url);
  if (!r.ok) throw new Error(await r.text());
  return r.json();
}

const meta_json = await fetchJSON(
  "https://raw.githubusercontent.com/haskell-wasm/ghc-wasm-bindists/main/meta.json"
);

function sri2hex(sri) {
  const [_algo, b64] = sri.split("-");

  return encoding.encodeHex(encoding.decodeBase64(b64));
}

function meta2ghcup(obj) {
  return {
    dlHash: sri2hex(obj.sriHash),
    dlSubdir: obj.ghcSubdir,
    dlUri: obj.mirrorUrl,
    dlOutput: `${sri2hex(obj.sriHash)}.tar.xz`,
  };
}

const ghcup_metadata = {
  toolRequirements: {},
  ghcupDownloads: { GHC: {} },
};

for (const flavour of ["gmp", "9.14", "9.12", "9.10", "9.8", "9.6"]) {
  const ver = meta_json[`wasm32-wasi-ghc-${flavour}`].ghcSubdir
    .replaceAll("ghc-", "")
    .replaceAll("-wasm32-wasi", "");
  const x86_64_linux = {
    unknown_versioning: meta2ghcup(meta_json[`wasm32-wasi-ghc-${flavour}`]),
  };
  ghcup_metadata.ghcupDownloads.GHC[`wasm32-wasi-${ver}`] = {
    viTags: [],
    viArch: {
      A_64: {
        Linux_UnknownLinux: x86_64_linux,
        Linux_Alpine: x86_64_linux,
      },
    },
  };

  if (meta_json[`wasm32-wasi-ghc-gmp-aarch64-darwin-${flavour}`]) {
    ghcup_metadata.ghcupDownloads.GHC[`wasm32-wasi-${ver}`].viArch.A_ARM64 = {
      Darwin: {
        unknown_versioning: meta2ghcup(
          meta_json[`wasm32-wasi-ghc-gmp-aarch64-darwin-${flavour}`]
        ),
      },
    };
  }

  if (meta_json[`wasm32-wasi-ghc-gmp-x86_64-darwin-${flavour}`]) {
    ghcup_metadata.ghcupDownloads.GHC[`wasm32-wasi-${ver}`].viArch.A_64.Darwin =
      {
        unknown_versioning: meta2ghcup(
          meta_json[`wasm32-wasi-ghc-gmp-x86_64-darwin-${flavour}`]
        ),
      };
  }

  if (meta_json[`wasm32-wasi-ghc-gmp-aarch64-linux-${flavour}`]) {
    const aarch64_linux = {
      unknown_versioning: meta2ghcup(
        meta_json[`wasm32-wasi-ghc-gmp-aarch64-linux-${flavour}`]
      ),
    };
    ghcup_metadata.ghcupDownloads.GHC[
      `wasm32-wasi-${ver}`
    ].viArch.A_ARM64.Linux_UnknownLinux = aarch64_linux;
    ghcup_metadata.ghcupDownloads.GHC[
      `wasm32-wasi-${ver}`
    ].viArch.A_ARM64.Linux_Alpine = aarch64_linux;
  }
}

await Deno.writeTextFile(
  "ghcup-wasm-0.0.9.yaml",
  yaml.stringify(ghcup_metadata, { lineWidth: 1024 })
);
