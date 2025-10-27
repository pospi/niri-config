#!/usr/bin/env bash
#
# build toolchains and base dependencies
#

# provides `add-apt-repository`
sudo apt install -y python3-launchpadlib

# needed to clone various repos
sudo apt install -y git git-lfs

# Rust build toolchain
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  # [follow installer prompts]
. "$HOME/.cargo/env"

# C build toolchain
sudo apt install -y gcc clang meson ninja-build
