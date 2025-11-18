#!/usr/bin/env bash
#
# miscellaneous utilities
#

. util/platform_flags.sh

# base rendering
sudo apt install -y xdg-desktop-portal-gtk xdg-desktop-portal-gnome

# privilege escalation helper & keyring
sudo apt-get install -y polkit-kde-agent-1 gnome-keyring

# used for `swaynag` confirmation helper
sudo apt install -y sway

# desktop background
sudo apt install -y swaybg

# media playback
sudo apt install -y playerctl

# bluetooth fix backport for 24.04
if [[ "$IS_2404" -eq 0 ]]; then
  sudo add-apt-repository -y ppa:giner/bluez
  sudo apt update
fi

# peripherals config utils
sudo apt install -y wdisplays brightnessctl bluez pavucontrol
cargo install bluetool
sudo usermod -aG video $USER  # to allow brightnessctl setting

# pomodoro timer
sudo apt install -y gnome-shell-pomodoro
