#!/usr/bin/env bash
#
# hardware-specific efficiency enhancements for System76 machines
#

. util/paths.sh

HAS_SYSTEM76=$(apt list system76-driver | grep '\[installed\]' -c)

if [[ "$HAS_SYSTEM76" -eq 1 ]]; then
  pushd "$TEMPDIR"
    git clone https://github.com/Kirottu/system76-scheduler-niri.git
    pushd system76-scheduler-niri
      cargo install --path .
    popd
  popd
fi
