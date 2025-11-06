#!/usr/bin/env bash
#
# app notifications supporting functionality
#

. util/paths.sh
. util/platform_flags.sh

# build dependencies
sudo apt install -y scdoc
if [[ "$IS_2204" -eq 0 && "$IS_UBUNTU" -eq 0 ]]; then
  sudo apt install -y -t bookworm-backports wayland-protocols
else
  sudo apt install -y wayland-protocols
fi

# util to trigger notifications via shell
sudo apt install -y libnotify-bin

pushd "$TEMPDIR"

  # build & install notifications daemon
  git clone https://github.com/emersion/mako.git
  pushd mako
    git checkout v1.10.0
    meson build
    ninja -C build
    sudo cp build/mako* /usr/local/bin/
  popd

popd
