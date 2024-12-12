#!/bin/bash

DISTRO_NAME='siyasat-linux'
DISTRO_PACKAGE="$DISTRO_NAME.tar.gz"

if [ -f $DISTRO_PACKAGE ]; then
    echo Cleaning up distro package.
    rm -f $DISTRO_PACKAGE
fi

echo Building Siyasat Linux salt-state packages.
./build.sh

if [ `whoami` != "root" ]; then
	echo "Must be root."
	exit
fi

#install sudo
su -
apt-get update
apt-get install sudo

sudo apt update
sudo apt install git

# some deps
echo "Installing some dependencies."
apt update && apt upgrade -y
apt install git curl -y

echo "Saltstack bootstrap..."
mkdir -p /etc/apt/keyrings
# Original keyring extension is .gpg but Salt Documentation shows .pgp as the extension for Public Keys (needs confirmation)
curl -fsSL https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public | sudo tee /etc/apt/keyrings/salt-archive-keyring.pgp
curl -fsSL https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.sources | sudo tee /etc/apt/sources.list.d/salt.sources

apt update
apt-get install -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y --allow-change-held-packages salt-common

echo "Extracting resources..."
rm -rf /opt/siyasat-linux
tar -xzvf $DISTRO_PACKAGE -C /

echo "Provisioning Siyasat Linux.."
salt-call -l debug state.apply distro

