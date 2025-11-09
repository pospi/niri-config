#!/usr/bin/env bash
#
# System idle handling & lockscreen functionality
#

. util/paths.sh

sudo apt install -y fish
sudo apt install -j jq  # needed to parse PipeWire output for media checks

pushd "$TEMPDIR"

  # lockscreen utility
  git clone https://github.com/jirutka/swaylock-effects.git
  pushd swaylock-effects
    git checkout v1.7.0.0
    meson build
    ninja -C build
    sudo ninja -C build install
    sudo chmod a+s /usr/local/bin/swaylock
  popd

  # idle management utility
  # (ideally this could be installed from apt, but packaged versions are outdated & throw unsupported idle protocol error)
  wget https://github.com/swaywm/swayidle/releases/download/1.8.0/swayidle-1.8.0.tar.gz
  tar -zxf ./swayidle-1.8.0.tar.gz
  pushd swayidle-1.8.0
    meson build/
    ninja -C build/
    sudo ninja -C build/ install
  popd

popd

# create wrapper script to configure locker
echo '#!/usr/bin/env bash

isLockActive() {
  lsStatus=$(ps cax | grep swaylock)
  if [[ -z $lsStatus ]]; then
    return 1
  fi
  return 0
}

doLock() {
  swaylock -f \
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
    "$@"
}

if isLockActive; then
  echo "Refusing to start Swaylock: process already active"
  exit 1
fi


case "$1" in
  immediate)
    doLock "${@:2}"
  ;;
  *)
    doLock --grace 2 --grace-no-mouse "$@"
  ;;
esac
' | sudo tee /opt/swaylock.sh
sudo chmod +x /opt/swaylock.sh

# idle management command
echo '#!/usr/bin/env bash

swayidle -w \
  timeout 605 "niri msg action power-off-monitors" \
  after-resume "niri msg action power-on-monitors" \
  timeout 606 "/opt/swaysleep.sh" \
  before-sleep "/opt/swaylock.sh immediate"
' | sudo tee /opt/swayidle.sh
sudo chmod +x /opt/swayidle.sh

# script to postpone sleep if media is playing
echo '#!/usr/bin/env bash

isMediaPlaying() {
  if [ -n $(which pw-dump) ]; then
    mediaStatus=$(pw-dump | jq ".[] | .info.state" | grep running | head -n 1)
    if [[ $mediaStatus == *"running"* ]]; then
      return 0
    fi
  elif [ -n $(which pulseaudio) ]; then
    mediaStatus=$(pacmd list-sink-inputs | grep state: | cut -d " " -f 2)
    if [[ $mediaStatus == *"RUNNING"* ]]; then
      return 0
    fi
  fi

  return 1
}

if isMediaPlaying; then
  echo "Postpone sleep: media is playing"

  # restart idle daemon timers...
  pkill swayidle
  /opt/swayidle.sh

  # ...but always trigger workstation lock
  /opt/swaylock.sh immediate

  exit 1
fi

systemctl suspend -i

' | sudo tee /opt/swaysleep.sh
sudo chmod +x /opt/swaysleep.sh

# integrate idle handling with systemd
echo "[Unit]
PartOf=graphical-session.target
After=graphical-session.target
Requisite=graphical-session.target

[Service]
ExecStart=/opt/swayidle.sh
Restart=on-failure" | tee "$HOME/.config/systemd/user/swayidle.service"
systemctl --user daemon-reload
systemctl --user add-wants niri.service swayidle.service
