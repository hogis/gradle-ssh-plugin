#!/bin/bash -xe
#
# Run acceptance tests on Travis CI.
#
# Requirements:
# - gradle-ssh-plugin must be installed (if version is not specified)
# - sshd must be running
# - sudo must be enabled without password
# - java must be installed

cd $(dirname $0)

# determine Gradle wrapper
[ "$GRADLE_VERSION" ] && ../gradlew wrapper || ln -s ../gradlew

# enable public key authentication
mkdir -m 700 -p -v                    $HOME/.ssh
ssh-keygen -t rsa -N ''            -f $HOME/.ssh/id_rsa
ssh-keygen -t rsa -N 'pass_phrase' -f $HOME/.ssh/id_rsa_pass
cat $HOME/.ssh/id_rsa.pub           > $HOME/.ssh/authorized_keys

# generate a known hosts file
ssh -o StrictHostKeyChecking=no \
    -o HostKeyAlgorithms=ssh-rsa \
    -o UserKnownHostsFile=$HOME/.ssh/known_hosts \
    -i $HOME/.ssh/id_rsa \
    localhost id
ssh-keygen -H -F localhost

# run tests
./gradlew -i -s -Pversion="${version:-SNAPSHOT}" test aggressiveTest

# run tests with ssh-agent
eval $(ssh-agent)
ssh-add $HOME/.ssh/id_rsa
./gradlew -i -s -Pversion="${version:-SNAPSHOT}" testWithAgent
ssh-agent -k
