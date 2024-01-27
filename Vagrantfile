# -*- mode: ruby -*-
# vi: set ft=ruby :

# https://docs.vagrantup.com
Vagrant.configure("2") do |config|
  config.vm.box = "debian/bookworm64"
  config.disksize.size = "20GB"

  config.vm.network "private_network", type: "dhcp"

  config.vm.provider "virtualbox" do |vb|
    vb.cpus = 4
    vb.memory = 2048
  end

  config.vm.provision "file", source: "~/.tmux.conf", destination: "~/"
  config.vm.provision "file", source: "~/.gitconfig", destination: "~/"
  config.vm.provision "file", source: "~/.ssh/github", destination: "~/"
  config.vm.provision "file", source: "~/.ssh/github.pub", destination: "~/"


  config.vm.provision "shell", inline: <<-SHELL
    # Update/upgrade the box
    sudo apt update
    sudo apt upgrade -y
    sudo apt full-upgrade -y
    sudo apt install -y curl vim git tmux tree htop

    # Install nix
    sh <(curl -L https://nixos.org/nix/install) --daemon

    # Move ssh keys
    mkdir /home/vagrant/.ssh/
    mv /home/vagrant/github /home/vagrant/github.pub /home/vagrant/.ssh/

    # Create setup.sh file
    echo "#!/usr/bin/env sh

# Aadd ssh keys
ssh-add ~/.ssh/github

# Clone the repositories
git clone git@github.com:section77/website.git
git clone git@github.com:section77/chaostreff-scheduler.git
" >> setup.sh

  # Set user and permissions for setup.sh
  chown vagrant /home/vagrant/setup.sh
  chmod +x /home/vagrant/setup.sh
  SHELL
end
