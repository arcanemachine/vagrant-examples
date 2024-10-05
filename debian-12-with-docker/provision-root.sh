#!/bin/sh

# To execute this script inside the VM, navigate to the directory that this
# script is located in, then run 'vagrant provision'.

set -e

# Fixes a non-fatal error when installing packages:
#  - `dpkg-reconfigure: unable to re-open stdin: No file or directory`
export DEBIAN_FRONTEND=noninteractive

echo "Upgrading packages..."
apt-get -y update
apt-get -y upgrade
