#!/usr/bin/env bash
#
# Taskbar & system tray

. util/paths.sh

# link Waybar configuration from this repository
# (repo must be cloned into `~/.config/niri`)
mkdir ~/.config/waybar
ln -s ~/.config/niri/waybar-config.jsonc ~/.config/waybar/config.jsonc

# build deps
sudo apt install -y fonts-font-awesome fonts-fork-awesome  # font dependency
sudo apt install -y libplayerctl-dev libpulse-dev \
  clang-tidy gobject-introspection libdbusmenu-gtk3-dev libevdev-dev \
  libfmt-dev libgirepository1.0-dev libgtk-3-dev libgtkmm-3.0-dev \
  libinput-dev libjsoncpp-dev libmpdclient-dev libnl-3-dev libnl-genl-3-dev \
  libsigc++-2.0-dev libspdlog-dev libwayland-dev scdoc upower \
  libxkbregistry-dev libmpdclient-dev

pushd "$TEMPDIR"

  # system tray (Waybar)
  # (compile from source to get latest version)
  git clone https://github.com/Alexays/Waybar
  pushd Waybar
    git checkout 0.14.0
    meson setup build
    ninja -C build
    sudo ninja -C build install
  popd

  # application taskbar for Waybar
  git clone https://github.com/LawnGnome/niri-taskbar.git
  pushd niri-taskbar
    cargo build --release
    sudo cp target/release/libniri_taskbar.so /opt/
  popd

popd
