#!/usr/bin/env bash

. util/platform_flags.sh

# Upstream backports from Debian repos
if [[ "$IS_2204" -eq 0 ]]; then
  sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 6ED0E7B82643E131 78DBA3BC47EF2265
  echo 'deb http://deb.debian.org/debian bookworm-backports main contrib' | sudo tee /etc/apt/sources.list.d/debian-backports.list
fi

# Ubuntu 22.04 pipewire-1.0.0 APT source
# (is already available in Pop!OS 22.04)
if [[ "$IS_2204" -eq 0 && "$IS_UBUNTU" -eq 0 ]]; then
  sudo add-apt-repository -y ppa:pipewire-debian/pipewire-upstream
  sudo add-apt-repository -y ppa:pipewire-debian/wireplumber-upstream
fi

sudo apt update
