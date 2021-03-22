#!/bin/bash

echo "Started"

apt-get update -y
apt-get install -y wget gnupg2
wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | apt-key add -
echo "deb https://packages.cloudfoundry.org/debian stable main" | tee /etc/apt/sources.list.d/cloudfoundry-cli.list
apt-get update -y
apt-get install cf7-cli -y
cf install-plugin cflocal -f
