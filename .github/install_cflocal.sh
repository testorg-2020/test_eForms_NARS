#!/bin/bash

ls -l $HOME/.cf/plugins
cf install-plugin cflocal -f
mkdir $GITHUB_WORKSPACE/docker
