#!/usr/bin/env bash
#
# miscellaneous utilities
#

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

# peripherals config utils
sudo apt install -y wdisplays brightnessctl blueman pavucontrol
sudo usermod -aG video $USER  # to allow brightnessctl setting

# pomodoro timer
sudo apt install -y gnome-shell-pomodoro
