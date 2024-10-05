#!/bin/sh
# shellcheck disable=SC1090,SC2016

# To execute this script inside the VM, navigate to the directory that this
# script is located in, then run 'vagrant provision'.

### ASDF ###
asdf_version=v0.14.0

echo "Configuring 'asdf'..."

echo "Checking if 'asdf' is installed..."
if [ ! -e "/$USER/.asdf" ]; then
  echo "'asdf' is not installed. Installing it now..."
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch ${asdf_version}
else
  echo "'asdf' is already installed. Skipping..."
fi

echo "Checking if shell environment loads 'asdf' config..."
if ! grep -q asdf ~/.bashrc; then
  echo "Adding 'asdf' config to '~/.bash_profile'..."

  # Add 'asdf' config to '~/.bash_profile' (for some reason, using '~/.bashrc'
  # isn't working in Debian VM)
  echo '. ~/.bashrc

# asdf
. "$HOME/.asdf/asdf.sh"
. "$HOME/.asdf/completions/asdf.bash"' >>~/.bash_profile
else
  echo "The shell environment is already configured for 'asdf'. Skipping..."
fi

echo "Adding 'asdf' plugins for Erlang and Elixir..."
"$HOME/.asdf/bin/asdf" plugin-add erlang
"$HOME/.asdf/bin/asdf" plugin-add elixir

echo "Finished configuring 'asdf'"

### DOCKER ###
echo "Checking if Docker is already installed..."

# Instructions taken from here:
#   - https://docs.docker.com/engine/install/debian/

if [ ! -e /usr/bin/docker ]; then
  echo "Docker has not been installed yet."
  echo "Installing and enabling Docker for non-root user..."

  echo "Uninstalling conflicting packages..."
  for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
    sudo apt-get remove $pkg
  done

  echo "Adding Docker's official GPG key..."
  sudo apt-get update
  sudo apt-get install -y ca-certificates curl
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  echo "Adding the repository to 'apt' sources..."
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
    sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
  sudo apt-get update

  echo "Installing the latest version of Docker..."
  sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

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

### GITLAB-RUNNER ###
echo "Configuring 'gitlab-runner' for non-root user..."

echo "Stopping and removing the 'systemd' service for the existing (root) user..."
sudo systemctl stop gitlab-runner
sudo gitlab-runner uninstall

echo "Installing the 'gitlab-runner' service for the non-root user..."
sudo gitlab-runner install \
  --service gitlab-runner \
  --user "$USER" \
  --working-directory "/home/$USER"

echo "Reloading the systemd units and startng the service for the non-root user..."
sudo systemctl daemon-reload
sudo systemctl start gitlab-runner

echo "Finished configuring 'gitlab-runner' for non-root user"

echo "*********************************************************************"
echo "DON'T FORGET TO REGISTER YOUR 'gitlab-runner' INSTANCE INSIDE THE VM!"
echo "                                                                     "
echo "                    'sudo gitlab-runner register'                    "
echo "                                                                     "
echo "*********************************************************************"

echo "done"
