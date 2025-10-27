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

## Installation

First, clone this repository to the standard Niri config location:

```bash
git clone https://github.com/pospi/niri-config.git $HOME/.config/niri
```

Setup scripts are broken down by feature. A complete installation can be run by executing [`install/_setup.sh`](./install/_setup.sh). You can define `NIRI_INSTALL_TMPDIR` prior to executing this script to change the location of downloaded archives used in compilation (defaults to `~/Downloads`). Note that temp files used in building packages are retained as they may be useful in later recompilation.

Commands are provided as a reference, and presume a freshly installed system. The following Debian-based OSes are tested and supported:

- Ubuntu 24.04
- Ubuntu 22.04
- Pop!OS 22.04

On other releases you may not need some dependencies, and on other distros you will need to adapt to your preferred package manager. Ubuntu 24.04 is presumed as the default. See usage of the platform detection logic in `install/util/platform_flags.sh` throughout the various scripts for more info.


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

- Prevent suspend when media is playing
- Get an app switcher working (see [here](https://github.com/Kiki-Bouba-Team/niri-switch/issues/14) and [here](https://github.com/isaksamsten/niriswitcher/issues/2)). Too much dependency hell on 22.04. For now, `niri-taskbar` is probably sufficient.

## License

WTFPL
