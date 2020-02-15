#!/bin/bash
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
