#!/usr/bin/env bash
#
# Niri window manager: main application
#

. util/paths.sh

# enable Wayland in GDM3 config
sudo sed -i -e 's/WaylandEnable=false/WaylandEnable=true/' /etc/gdm3/custom.conf

# install system dependencies for compiling Niri
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 6ED0E7B82643E131 78DBA3BC47EF2265
echo 'deb http://deb.debian.org/debian bookworm-backports main contrib' | sudo tee /etc/apt/sources.list.d/debian-backports.list
sudo apt update
sudo apt install -y libclang-dev libudev-dev libgbm-dev libxkbcommon-dev libegl1-mesa-dev libwayland-dev libdbus-1-dev libsystemd-dev libseat-dev libpipewire-0.3-dev libpango1.0-dev libdisplay-info-dev

pushd "$TEMPDIR"
  # libinput-dev is outdated & needs manual compilation,
  # but ideally could be installed from `bookworm-backports` above
  sudo apt install -y libev-dev libevdev-dev libmtdev-dev libwacom-dev libgtk-3-dev
  git clone https://gitlab.freedesktop.org/libinput/libinput
  pushd libinput
    git checkout 1.29.1
    meson setup --prefix=/usr builddir/
    ninja -C builddir/
    sudo ninja -C builddir/ install
  popd

  # build & install Niri window manager
  git clone https://github.com/YaLTeR/niri.git
  pushd niri
    git checkout v25.08
    cargo build --release

    sudo cp target/release/niri   /usr/local/bin/
    sudo cp resources/niri-session  /usr/local/bin/
    sudo mkdir /usr/local/share/wayland-sessions/
    sudo cp resources/niri.desktop  /usr/local/share/wayland-sessions/
    sudo mkdir /usr/local/share/xdg-desktop-portal/
    sudo cp resources/niri-portals.conf   /usr/local/share/xdg-desktop-portal/
    sed -i -e 's@/usr/bin/niri@/usr/local/bin/niri@' resources/niri.service
    sudo cp resources/niri.service /etc/systemd/user/
    sudo cp resources/niri-shutdown.target /etc/systemd/user/
  popd
popd
