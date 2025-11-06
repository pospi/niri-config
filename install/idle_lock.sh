#!/usr/bin/env bash
#
# System idle handling & lockscreen functionality
#

. util/paths.sh

sudo apt install -y fish

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

# integrate idle handling with systemd
echo "[Unit]
PartOf=graphical-session.target
After=graphical-session.target
Requisite=graphical-session.target

[Service]
ExecStart=/usr/local/bin/swayidle -w timeout 605 'niri msg action power-off-monitors' timeout 606 'systemctl suspend -i' before-sleep '/opt/swaylock.sh immediate' after-resume 'niri msg action power-on-monitors'
Restart=on-failure" | tee "$HOME/.config/systemd/user/swayidle.service"
systemctl --user daemon-reload
systemctl --user add-wants niri.service swayidle.service
