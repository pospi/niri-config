#!/usr/bin/env bash
#
# Task switcher (alt-tab like functionality)
#
# Ubuntu 24.04+ only due to outdated GTK on 22.04
#

. util/paths.sh
. util/platform_flags.sh

if [[ $LT_2404 -eq 0 ]]; then
  echo "Sorry! Task switcher only available on 24.04+ distros."
  exit 1
fi

sudo apt install -y libwayland-dev wayland-protocols libgtk-4-dev \
                    gobject-introspection libgirepository1.0-dev \
                    gtk-doc-tools valac

pushd "$TEMPDIR"
  git clone https://github.com/wmww/gtk4-layer-shell.git
  pushd gtk4-layer-shell
    git checkout v1.3.0
    meson setup build
    ninja -C build
    sudo ninja -C build install
    sudo ldconfig
  popd

  git clone https://github.com/Kiki-Bouba-Team/niri-switch.git
  pushd niri-switch
    git checkout v0.2.1
    cargo install --path .
  popd
popd
