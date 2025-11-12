# Workstation configuration for [Niri](https://yalter.github.io/niri/) window manager

A somatically, haptically & neurologically informed window manager configuration to support an autonomic 2D spatial OS interface.

<p style="text-align: center"><strong>&mdash; or &mdash;</strong></p>

"Turns your computer into a thinking box that you can drive like a Nintendo on even the lowest common denominator hardware available."

*(Imagine it like you're spreading out thoughts on the floor.)*

Great for ADHD sufferers, multitasking workflows, and those who struggle with unproductive tangenting.

> (You could bring that un-usably slow discarded Windows laptop back to life with these tools and a relatively quick & simple [Ubuntu Desktop](https://ubuntu.com/desktop) installation! I *guarantee* it will be a much faster & more pleasant machine to use than when it was Microsoft-tainted.)

<img width="1920" height="1080" alt="A fullscreen screenshot of a single-screen computer desktop UI, with some tangenting windows sprawling out from the focused one both horizontally and vertically." title="This is just standard Niri, but this is what it looks like." src="https://github.com/user-attachments/assets/30c1f86a-87de-462e-bb37-28dc7794597a" />

## Features & integrations

- Ergonomically considered [keybindings](#keybindings) for maximum work efficiency:
    - The arrow keys move things.
    - Intuitive keychords allowing interactions to be composed and 'played' like notes on a synth.
    - Windows size horizontally to enable switching focus to one's previous task by wiggling the mouse pointer at the border between them.
    - All OS functionality is instantly (sub-200ms) accessible via one's (likely) most muscularly developed fingers.
    - Zoom in/out to overview with a single key chord, maintaining consistent navigation with regular zoomlevel.
    - [Conceptually lean](#conceptual-model) & quick to learn!
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

## Keybindings

### Conceptual model

For the purposes of this description, the Niri window manager is considered to be organised as follows:

- Opened application **windows** are auto-placed side by side in **columns** on an infinitely scrolling **row**.
- **Columns** may be subdivided into multiple **windows**.
- Groups of **rows** are organised vertically and displayed, one at a time, to the full height of a physical computer **monitor**.
- By default, a **column** occupies 100% of the available **monitor** space.
- **Columns** can be "subdivided" such that individual **windows** no longer take up the full height of the **monitor**.
    - Once subdivided, **windows** are said to be **stacked** within their **column**.

### Interaction design

TLDR; it's designed to feel somatically similar to working with text editing on Linux & Windows machines.

Key chords are played compositionally, which means that you hold more of them down to combine interactions.

Holding `Mod` (or `Win`) activates window system interaction mode, and takes focus away from the currently active application window.

### Chords

1. `Mod` activates **window** interaction mode.
    1. `Mod`+`arrow keys` = change focused **window**
    2. `Mod`+`Shift`+`arrow keys` = move focused area:
        - **columns** move left/right *within* a **row**
        - **windows** move up/down *within* a **column** 
            - and out to the adjacent **row** when it reaches the top/bottom of the **column**
    3. `Mod`+(`Page_Down`|`Page_Up`) = change focus between **rows**
        - `Mod`+`Shift`+(`Page_Down`|`Page_Up`) = move focused **column** between **rows**
    4. `Mod`+(`Home`|`End`) = jump to start/end of **row**
        - `Mod`+`Shift`+(`Home`|`End`) = move the focused **column** to start/end of **row**
2. `Ctrl`+`Alt` activates **monitor** interaction mode.
    1. `Ctrl`+`Alt`+`arrow keys` = change focused **monitor**
    2. `Ctrl`+`Alt`+`Shift`+`arrow keys` = moves **columns** between **monitors**
    3. `Ctrl`+`Alt`+`Shift`+(`Page_Down`|`Page_Up`) = moves **rows** up/down *within* the same **monitor**
    4. `Ctrl`+`Alt`+`Shift`+(`Home`|`End`) = moves **rows** left/right *among* **monitors**
3. `Mod`+`R` toggles focused **column** widths among presets
    - (`Mod`+`Shift`+`R` to go backwards)
4. `Mod`+`E` toggles focused **window** heights among presets
    - (`Mod`+`Shift`+`E` to go backwards)
    - (`Mod`+`Ctrl`+`E` to reset to full height)
5. `Mod`+(`[`|`]`) will split & shuffle stacked **windows** left/right between **columns** if there is space available
6. `Mod`+`S` or `Mod`+`O` = zoom out to the desktop overview. Press again to return to standard view. Windows can be rearranged via the same keys as normal, or by clicking & dragging with the mouse.

Use of the `scroll wheel` is alike `arrow keys`- i.e. it changes focus vertically between **rows**; and when combined with `Ctrl` changes focus horizontally between **columns**.

On a touchpad, you can use three-finger drag to move around between **windows**; and four-finger drag to zoom out to the desktop overview.

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

### Scheduler for System76 hardware

There is a handy little script for owners of such machines that raises the CPU priority of the foreground window for better power management. It's already configured as a start script in the configuration (it'll just fail silently if not present). See [`install/system76_hardware.sh`](./install/system76_hardware.sh) for details.

## License

WTFPL
