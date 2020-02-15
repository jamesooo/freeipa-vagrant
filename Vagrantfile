# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|
  config.vm.define "ipa" do |ipa|
    ipa.vm.box = "centos/7"
    ipa.vm.box_version = "1905.1"
    ipa.vm.network "private_network", ip: "192.168.33.10"
    ipa.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus = "2"
    end
    config.vm.provision "shell", path: 'general/update.sh'
    config.vm.provision "shell", path: 'server/hostname.sh'
    config.vm.provision "shell", path: 'server/swap.sh'
    config.vm.provision "shell", path: 'server/rng.sh'
    config.vm.provision "shell", path: 'server/ipa.sh'
  end
end
