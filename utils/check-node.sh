#!/usr/bin/env bash

set -uo pipefail

nix path-info --inputs-from . nixpkgs#legacyPackages.x86_64-darwin.nodejs_latest

nix path-info --inputs-from . nixpkgs#legacyPackages.aarch64-darwin.nodejs_latest

nix path-info --inputs-from . nixpkgs#legacyPackages.aarch64-linux.nodejs_latest

nix path-info --inputs-from . nixpkgs#legacyPackages.x86_64-linux.nodejs_latest
