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
    config.vm.provision "shell", inline: <<-SHELL
      # normally set this as ipa.vm.hostname but freeipa needs to resolve to the public addr
      if [ ! $(hostname) = ipa.jamesooo.private ]; then
        hostname ipa.jamesooo.private
        echo "ipa.jamesooo.private" | tee /etc/hostname
        echo "192.168.33.10 ipa.jamesooo.private ipa" | tee -a /etc/hosts
      fi
      # centos comes with a swapfile that just isn't big enough for ipa so we'll add more
      if [ ! -f /ipaswapfile ]; then
        echo 'swapfile not found. Adding swapfile.'
        dd if=/dev/zero of=/ipaswapfile count=4096 bs=1MiB
        chmod 600 /ipaswapfile
        mkswap /ipaswapfile
        echo '/ipaswapfile none swap defaults 0 0' >> /etc/fstab
        swapon -a
      else
        echo 'swapfile found. No changes made.'
      fi
      # update to get things ready
      yum update -y
      # install and start the random number generator to avoid freeipa running out of entrophy
      yum install -y rng-tools
      systemctl start rngd
      systemctl enable rngd
      systemctl enable firewalld
      systemctl start firewalld
      # if ipa-server is already installed we need to uninstall it
      if [ -f /var/log/ipaserver-install.log ]; then
        ipa-server-install --uninstall --unattended
      fi
      # install and configure ipa-server
      yum install -y freeipa-server ipa-server-dns
      ## set the firewall to allow freeipa
      firewall-cmd --add-service=freeipa-ldap --add-service=freeipa-ldaps
      firewall-cmd --add-service=freeipa-ldap --add-service=freeipa-ldaps --permanent
      ipa-server-install \
        --unattended \
        --setup-dns \
        --forwarder 1.1.1.1 \
        --ds-password=dm_password \
        --admin-password=admin_password \
        --ip-address 192.168.33.10 \
        --no-host-dns \
        --no-dnssec-validation \
        --hostname=ipa.jamesooo.private \
        --domain=jamesooo.private \
        --realm=JAMESOOO.PRIVATE \
        --mkhomedir
    SHELL
  end
end
