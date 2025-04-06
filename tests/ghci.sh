#!/usr/bin/env bash

set -euo pipefail

GHCI_SCRIPT='foreign import javascript "new Promise(res => setTimeout(res, 1024, 114514))" x :: IO Int\nx\n'

echo -e "$GHCI_SCRIPT" | wasm32-wasi-ghc --interactive -package ghc -package Cabal

FIREFOX_PATH=$(type -P firefox || echo "")

if [[ $FIREFOX_PATH != "" ]]; then
  echo -e "$GHCI_SCRIPT" | wasm32-wasi-ghc --interactive -fghci-browser -fghci-browser-puppeteer-launch-opts="{\"browser\":\"firefox\",\"executablePath\":\"$FIREFOX_PATH\"}"
fi

CHROME_PATH=$(type -P google-chrome-stable || type -P chromium || echo "")

if [[ $CHROME_PATH != "" ]]; then
  echo -e "$GHCI_SCRIPT" | wasm32-wasi-ghc --interactive -fghci-browser -fghci-browser-puppeteer-launch-opts="{\"browser\":\"chrome\",\"protocol\":\"webDriverBiDi\",\"executablePath\":\"$CHROME_PATH\",\"args\":[\"--no-sandbox\"]}"
fi
