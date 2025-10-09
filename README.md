# Workstation configuration for [Niri](https://yalter.github.io/niri/) window manager

## Features & integrations

- [ULauncher](https://ulauncher.io/) for app launching
- [Mako](https://github.com/emersion/mako) for desktop notifications
- Latest [Waybar](https://github.com/Alexays/Waybar) for system tray
    - Active workspace and window indicators
    - [Niri taskbar](https://github.com/LawnGnome/niri-taskbar) to show running app icons
- Suspend / reboot / poweroff commands with confirmation (using [Sway](https://swaywm.org/)'s `swaynag` command)
- Automatic suspend when laptop lid closed
- Lockscreen via [Swaylock-effects](https://github.com/jirutka/swaylock-effects)
- Quick access to peripherals config via popup menu
- [Playerctl](https://github.com/altdesktop/playerctl) to manage media hotkeys
- Screencasting functionality, with active window highlighting & notification hiding
- LCD backlight adjustment & volume controls all work
- A reasonably intuitive set of custom keybindings

## Full setup instructions

These commands presume a freshly installed system running Ubuntu 22.04 LTS (or derivative such as Pop!OS 22.04). On more recent versions you may not need some dependencies, and on other distros you will need to adapt to your preferred package manager.

```bash
# base utilities

sudo apt install -y python3-launchpadlib # provides `add-apt-repository`
sudo apt install -y git git-lfs # to clone various repos

# enable Wayland in GDM3 config
sudo sed -i -e 's/WaylandEnable=false/WaylandEnable=true/' /etc/gdm3/custom.conf

# install system dependencies for compiling Niri
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 6ED0E7B82643E131 78DBA3BC47EF2265
echo 'deb http://deb.debian.org/debian bookworm-backports main contrib' | sudo tee /etc/apt/sources.list.d/debian-backports.list
sudo apt update
sudo apt install -y gcc clang libudev-dev libgbm-dev libxkbcommon-dev libegl1-mesa-dev libwayland-dev libdbus-1-dev libsystemd-dev libseat-dev libpipewire-0.3-dev libpango1.0-dev libdisplay-info-dev

# get a Rust toolchain installed
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  # [follow installer prompts]
. "$HOME/.cargo/env"

pushd ~/Downloads
  # libinput-dev is outdated & needs manual compilation,
  # but ideally could be installed from `bookworm-backports` above
  sudo apt install -y meson ninja-build libev-dev libevdev-dev libmtdev-dev libwacom-dev libgtk-3-dev
  git clone https://gitlab.freedesktop.org/libinput/libinput
  pushd libinput
    git checkout 1.29.1
    meson setup --prefix=/usr builddir/
    ninja -C builddir/
    sudo ninja -C builddir/ install
  popd

  # build Niri window manager
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

  # build notifications daemon
  sudo apt install -y scdoc
  git clone https://github.com/emersion/mako.git
  pushd mako
    git checkout v1.10.0
    meson build
    ninja -C build
    sudo cp build/mako* /usr/local/bin/
  popd

  # X11 compat layer
  sudo apt install -y xcb libxcb-cursor-dev xwayland
  git clone https://github.com/Supreeeme/xwayland-satellite.git
  pushd xwayland-satellite
    git checkout a9188e7
    cargo build --release -F systemd

    sudo cp target/release/xwayland-satellite     /usr/local/bin/
    sudo cp resources/xwayland-satellite.service  /etc/systemd/user/
  popd

  # system tray (Waybar)
  # (compile from source to get latest version)
  sudo apt install -y fonts-font-awesome fonts-fork-awesome  # font dependency
  sudo apt install -y llibplayerctl-dev libpulse-dev \
    clang-tidy gobject-introspection libdbusmenu-gtk3-dev libevdev-dev \
    libfmt-dev libgirepository1.0-dev libgtk-3-dev libgtkmm-3.0-dev \
    libinput-dev libjsoncpp-dev libmpdclient-dev libnl-3-dev libnl-genl-3-dev \
    libsigc++-2.0-dev libspdlog-dev libwayland-dev scdoc upower \
    libxkbregistry-devlibmpdclient-dev
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
    sudo cp target/release/libniri_taskbar.so /opt/
  popd

  # lockscreen utility
  sudo apt install -y fish
  git clone https://github.com/jirutka/swaylock-effects.git
  pushd swaylock-effects
    git checkout v1.7.0.0
    meson build
    ninja -C build
    sudo ninja -C build install
    sudo chmod a+s /usr/local/bin/swaylock
  popd
popd

# base rendering
sudo apt install -y xdg-desktop-portal-gtk xdg-desktop-portal-gnome gnome-keyring
# privilege escalation helper
sudo apt-get install -y polkit-kde-agent-1
# used for `swaynag` confirmation helper
sudo apt install -y sway
# desktop background, idle watching
sudo apt install -y swaybg swayidle
# trigger notifications via shell
sudo apt install -y libnotify-bin
# media playback
sudo apt install -y playerctl

# app launcher
sudo add-apt-repository ppa:agornostal/ulauncher -y
sudo apt update
sudo apt install -y ulauncher
# [install extensions through settings UI:]
#   - https://github.com/Ulauncher/ulauncher-emoji
#   - https://github.com/wckd02/port-killer-ulauncher

# create wrapper script to configure locker
echo '#!/usr/bin/env bash
swaylock \
  --screenshots \
  --clock \
  --datestr "%a %b %-m %Y" \
  --indicator \
  --effect-pixelate 25 \
  --effect-vignette 0.5:0.5 \
  --ring-color 5BCEFA \
  --key-hl-color F5A9B8 \
  --text-color FFFFFF \
  --line-color 00000000 \
  --inside-color 00000088 \
  --separator-color 00000000 \
  --grace 2 \
  --grace-no-mouse \
  "$@"
' | sudo tee /opt/swaylock.sh
sudo chmod +x /opt/swaylock.sh

# integrate idle handling
echo '[Unit]
PartOf=graphical-session.target
After=graphical-session.target
Requisite=graphical-session.target

[Service]
ExecStart=/usr/bin/swayidle -w timeout 601 'niri msg action power-off-monitors' timeout 600 '/opt/swaylock.sh -f' before-sleep '/opt/swaylock.sh -f'
Restart=on-failure' | tee "$HOME/.config/systemd/user/swayidle.service"
systemctl --user daemon-reload
systemctl --user add-wants niri.service swayidle.service

# peripherals config utils
sudo apt install -y wdisplays brightnessctl blueman pavucontrol
sudo usermod -aG video $USER  # to allow brightnessctl setting

# other useful utilities
sudo apt install -y gnome-shell-pomodoro


# All done! Now complete setup by cloning & integrating this repo:
git clone https://github.com/pospi/niri-config.git $HOME/.config/niri
$HOME/.config/niri/install.sh
```


## Scheduler for System76 hardware

There is a handy little script for owners of such machines that raises the priority of the foreground window to give it CPU priority. It's already configured as a start script in the configuration (it'll just fail silently if not present). You can set it up with these commands:

```bash
pushd ~/Downloads
  git clone https://github.com/Kirottu/system76-scheduler-niri.git
  pushd system76-scheduler-niri
    cargo install --path .
  popd
popd
```

## To-do

- Get an app switcher working (see [here](https://github.com/Kiki-Bouba-Team/niri-switch/issues/14) and [here](https://github.com/isaksamsten/niriswitcher/issues/2)). Too much dependency hell on 22.04. For now, `niri-taskbar` is probably sufficient.

## License

WTFPL