#!/bin/bash
# install and start the random number generator to avoid freeipa running out of entrophy
yum install -y rng-tools
systemctl start rngd
systemctl enable rngd
