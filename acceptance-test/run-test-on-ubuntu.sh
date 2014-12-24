#!/bin/bash -xe
#
# Run acceptance tests on Ubuntu container.
#
# Requirements:
# - gradle-ssh-plugin must be installed (if version is not specified)
# - java must be available

apt-get update
apt-get install -y openssh-server

# reset shell prompt
echo 'PS1="\u@\H \w \$ "' >> ~/.bashrc

# start a SSH server
mkdir -p /var/run/sshd
/usr/sbin/sshd

# run the test
./run-test.sh
