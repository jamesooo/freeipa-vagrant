#!/bin/bash
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
