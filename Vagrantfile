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
      echo CONFIGURING named
      yum install -y bind bind-utils
      cat <<EOF | sudo tee /etc/named.conf
options {
  listen-on port 53 { 127.0.0.1; 192.168.33.10; };
  listen-on-v6 port 53 { ::1; };
};
acl "trusted" {
  192.168.33.0/24;
  localhost;
};
include "/etc/named/named.conf.local";
EOF

      cat <<EOF | sudo tee /etc/named/named.conf.local
zone "ipa.jamesooo.private" {
  type master;
  file "/etc/named/zones/ipa.jamesooo.private";
};
zone "33.168.192.in-addr.arpa" {
  type master;
  file "/etc/named/zones/ipa.33.168.192.in-addr.arpa";
};
EOF

      sudo chmod 755 /etc/named
      sudo mkdir -p /etc/named/zones

      cat <<EOF | sudo tee /etc/named/zones/ipa.jamesooo.private
\\\$TTL 30
@    IN    SOA    ipa.jamesooo.private. ipa.jamesooo.private. (
             3  ; Serial
        604800  ; Refresh
         86400  ; Retry
       2419200  ; Expire
        604800 ); Negative Cache TTL
; name servers - NS records
    IN    NS    ns1.jamesooo.private.
; name servers - A records
ns1.jamesooo.private.    IN    A    192.168.33.10
; host servers - A records
ipa.jamesooo.private.    IN    A    192.168.33.10
EOF

      cat <<EOF | sudo tee /etc/named/zones/ipa.33.168.192.in-addr.arpa
\\\$TTL 30
@    IN    SOA    ipa.jamesooo.private.33.168.192.in-addr.arpa ipa.jamesooo.private. (
      20200212   ; Serial
      604800     ; Refresh
      86400      ; Retry
      2419200    ; Expire
      30       ) ; Minimum TTL
; name servers - NS records
@     IN    NS    ns1.jamesooo.private.
; PTR Records
10    IN    PTR    ns1.jamesooo.private.    ; 192.168.33.10
10    IN    PTR    ipa.jamesooo.private.    ; 192.168.33.10
EOF
      systemctl enable named
      systemctl start named
      firewall-cmd --permanent --add-port=53/tcp
      firewall-cmd --permanent --add-port=53/udp
      echo "nameserver 192.168.33.10" | tee /etc/resolv.conf
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
        --auto-forwarders \
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
