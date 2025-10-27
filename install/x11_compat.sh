#!/usr/bin/env bash
#
# X11 compat layer
#

. util/paths.sh

sudo apt install -y xcb libxcb-cursor-dev xwayland

pushd "$TEMPDIR"

  git clone https://github.com/Supreeeme/xwayland-satellite.git
  pushd xwayland-satellite
    git checkout a9188e7
    cargo build --release -F systemd

    sudo cp target/release/xwayland-satellite     /usr/local/bin/
    sudo cp resources/xwayland-satellite.service  /etc/systemd/user/
  popd

popd
