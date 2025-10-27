#!/usr/bin/env bash
#
# app notifications supporting functionality
#

. util/paths.sh

# trigger notifications via shell
sudo apt install -y libnotify-bin

pushd "$TEMPDIR"

  # build & install notifications daemon
  sudo apt install -y scdoc
  git clone https://github.com/emersion/mako.git
  pushd mako
    git checkout v1.10.0
    meson build
    ninja -C build
    sudo cp build/mako* /usr/local/bin/
  popd

popd
