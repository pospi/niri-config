#!/usr/bin/env bash
#
# Niri window manager: main application
#

. util/paths.sh
. util/platform_flags.sh

# enable Wayland in GDM3 config
sudo sed -i -e 's/WaylandEnable=false/WaylandEnable=true/' /etc/gdm3/custom.conf

# install system dependencies for compiling Niri
sudo apt install -y libclang-dev libudev-dev libgbm-dev libxkbcommon-dev libegl1-mesa-dev libwayland-dev libdbus-1-dev libsystemd-dev libseat-dev libpipewire-0.3-dev libpango1.0-dev libdisplay-info-dev

# Ubuntu 22.04 pipewire-1.0.0 build deps
if [[ "$IS_2204" -eq 0 && "$IS_UBUNTU" -eq 0 ]]; then
  sudo apt install -y gstreamer1.0-pipewire libpipewire-0.3-{0,dev,modules} libspa-0.2-{bluetooth,dev,jack,modules} pipewire{,-{audio-client-libraries,pulse,bin,jack,alsa,v4l2,libcamera,locales,tests}}
fi

pushd "$TEMPDIR"

  if [[ "$IS_2204" -eq 0 ]]; then
    # libinput-dev is outdated & needs manual compilation in 22.04
    sudo apt install -y libev-dev libevdev-dev libmtdev-dev libwacom-dev libgtk-3-dev
    git clone https://gitlab.freedesktop.org/libinput/libinput
    pushd libinput
      git checkout 1.29.1
      meson setup --prefix=/usr builddir/
      ninja -C builddir/
      sudo ninja -C builddir/ install
    popd
  else
    # can be installed from system registries in 24.04
    sudo apt install libinput libinput-dev
  fi

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
