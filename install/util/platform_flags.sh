#!/usr/bin/env bash
#
# Platform sniffing used for conditional installation checks
#

DISTRO_ID=$(lsb_release -i | cut -f 2)
RELEASE_ID=$(lsb_release -r | cut -f 2)

# checks stored as exit codes (0 == truthy)
IS_UBUNTU=$( [[ "$DISTRO_ID" == "Ubuntu" ]]; echo $? )
IS_2204=$( [[ "$RELEASE_ID" == "22.04" ]]; echo $? )
LT_2404=$( [[ ! "$RELEASE_ID" < "24.04" ]]; echo $? )
