# Vagrant Examples

A collection of plug-and-play scenarios for Vagrant.

## Setup

Setup instructions for Debian (using `libvirt` instead of `virtualbox`) can be found [here](https://opensource.com/article/21/10/vagrant-libvirt)

- Install `vagrant`, `libvirt`, and other dependencies:

```
sudo apt install vagrant ruby-libvirt \
qemu libvirt-daemon-system libvirt-clients ebtables \
dnsmasq-base libxslt-dev libxml2-dev libvirt-dev \
zlib1g-dev ruby-dev libguestfs-tools
```

- The stuff in this section may not need to be done. See what happens:
  - Add user to group `libvirt`:
    - `sudo usermod --append --groups libvirt $USER`
  - Logout and log back in
  - Confirm that user is in group `libvirt`:
    - `groups | grep -o libvirt`

- Install the `vagrant-libvirt` plugin:
  - `vagrant plugin install vagrant-libvirt`

- Start a vagrant environment:
  - `vagrant init debian/bullseye64`
  - `vagrant up --provider=libvirt`
  - `vagrant ssh`

- When you are finished, destroy the Vagrant environment:
  - `vagrant destroy`


# Vagrant + Ansible

After navigating to the directory that contains your Vagrantfile:

- Add the following config to the bottom of the Vagrantfile, before the final `end` line:

```
  # Provisioning configuration for Ansible.
  config.vm.provision "ansible" do |ansible|
  ansible.playbook = "playbook.yml"
  end
```

- Create the playbook you want to run, named `playbook.yml` (as specified in the Vagrantfile).
- Run `vagrant provision` to run the playbook in your Vagrant VM.
