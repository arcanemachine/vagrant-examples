#!/bin/sh

# To execute this script inside the VM, navigate to the directory that this
# script is located in, then run 'vagrant provision'.

set -e

arch=amd64

# Fixes a non-fatal error when installing packages:
#  - `dpkg-reconfigure: unable to re-open stdin: No file or directory`
export DEBIAN_FRONTEND=noninteractive

echo "Upgrading packages..."
apt-get -y update
apt-get -y upgrade

echo "Installing generic dependencies..."
apt-get -y install curl git
apt-get -y install libncurses5-dev # Fixes warning when installing Erlang via 'asdf'

### ERLANG ###
echo "Installing Erlang dependencies..."

# Ref: https://github.com/asdf-vm/asdf-erlang?tab=readme-ov-file#debian-12-bookworm
apt-get -y install build-essential autoconf m4 libncurses-dev libwxgtk3.2-dev libwxgtk-webview3.2-dev libgl1-mesa-dev libglu1-mesa-dev libpng-dev libssh-dev unixodbc-dev xsltproc fop libxml2-utils openjdk-17-jdk

### GITLAB-RUNNER ###
echo "Checking if 'gitlab-runner' is installed..."
if [ ! -f /usr/bin/gitlab-runner ]; then
  echo "'gitlab-runner' is not installed. Installing it now..."
  echo "Fetching 'gitlab-runner'..."
  mkdir /tmp/gitlab-runner-installer
  cd /tmp/gitlab-runner-installer
  curl -LJO "https://s3.dualstack.us-east-1.amazonaws.com/gitlab-runner-downloads/latest/deb/gitlab-runner_${arch}.deb"

  echo "Installing 'gitlab-runner'..."
  sudo dpkg -i /tmp/gitlab-runner-installer/gitlab-runner_${arch}.deb

  echo "Removing the 'gitlab-runner' installer directory..."
  rm -rf /tmp/gitlab-runner-installer
else
  echo "'gitlab-runner' is installed. Skipping..."
fi
