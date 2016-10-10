#!/bin/bash

OPENSTACK_VERSION=stable/mitaka

sudo apt-get update -qqy
sudo apt-get install -qqy git

if [ ! -f ~/.ssh/id_rsa ]; then
  ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
fi

devstack_home="$HOME/devstack"

if [ ! -d "$devstack_home" ]; then
  git clone https://github.com/openstack-dev/devstack.git "$devstack_home"
fi

cd "$devstack_home" && git checkout $OPENSTACK_VERSION

cat > "local.conf" <<EOF
[[local|localrc]]

DEST=/opt/stack
LOGFILE=/opt/stack/logs/stack.sh.log
SCREEN_LOGDIR=/opt/stack/logs/screen

ADMIN_PASSWORD=admin
DATABASE_PASSWORD=\$ADMIN_PASSWORD
RABBIT_PASSWORD=\$ADMIN_PASSWORD
SERVICE_PASSWORD=\$ADMIN_PASSWORD
SERVICE_TOKEN=\$ADMIN_PASSWORD

HOST_IP=192.168.42.11
FLAT_INTERFACE=eth1
FIXED_RANGE=10.1.1.0/24
FIXED_NETWORK_SIZE=256
FLOATING_RANGE=192.168.42.128/25

# Enable the Ceilometer devstack plugin
enable_plugin ceilometer https://git.openstack.org/openstack/ceilometer.git $OPENSTACK_VERSION

# Enable the aodh alarming services
enable_plugin aodh https://git.openstack.org/openstack/aodh $OPENSTACK_VERSION
EOF

./stack.sh
