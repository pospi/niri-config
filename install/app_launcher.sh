#!/usr/bin/env bash
#
# app launcher
#
# [install extensions through settings UI:]
#   - https://github.com/Ulauncher/ulauncher-emoji
#   - https://github.com/wckd02/port-killer-ulauncher
#

. util/paths.sh

pushd "$TEMPDIR"

  wget https://github.com/Ulauncher/Ulauncher/releases/download/v6.0.0-beta27/ulauncher_6.0.0.beta27_all.deb
  sudo dpkg -i ulauncher_6.0.0.beta27_all.deb
  sudo apt install -y # autoresolve any dependency issues

popd
