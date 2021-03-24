#!/bin/bash

apt-get update && apt-get install -y \
    wget \
    gpupg2 \
    && rm -rf /var/lib/apt/lists/*

wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | apt-key add -
echo "deb https://packages.cloudfoundry.org/debian stable main" | tee /etc/apt/sources.list.d/cloudfoundry-cli.list

apt-get update && apt-get install -y \
    cf7-cli \
    && rm -rf /var/lib/apt/lists/*
