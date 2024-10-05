#!/bin/sh
# shellcheck disable=SC1090,SC2016

# To execute this script inside the VM, navigate to the directory that this
# script is located in, then run 'vagrant provision'.

### DOCKER ###
echo "Checking if Docker is already installed..."

# Instructions taken from here:
#   - https://docs.docker.com/engine/install/debian/

if [ ! -e /usr/bin/docker ]; then
  echo "Docker has not been installed yet."
  echo "Installing and enabling Docker for non-root user..."

  echo "Installing the latest version of Docker..."
  sudo apt-get install docker.io

  echo "Ensuring the Docker daemon has started..."
  sudo systemctl start docker

  echo "Making sure the Docker daemon is active and running..."
  sudo systemctl status docker

  echo "Making sure Docker starts on boot..."
  sudo systemctl enable docker

  echo "Enabling Docker for user '$USER'..."
  sudo usermod -aG docker "$USER"

  echo "Finished installing and configuring Docker"
else
  echo "Docker is already installed. Skipping..."
fi

echo "done"
