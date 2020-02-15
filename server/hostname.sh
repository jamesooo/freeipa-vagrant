#!/bin/bash
# normally set this as ipa.vm.hostname but freeipa needs to resolve to the public addr
if [ ! $(hostname) = ipa.jamesooo.private ]; then
    hostname ipa.jamesooo.private
    echo "ipa.jamesooo.private" | tee /etc/hostname
    echo "192.168.33.10 ipa.jamesooo.private ipa" | tee -a /etc/hosts
fi
