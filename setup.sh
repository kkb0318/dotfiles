#!/bin/bash

AQUA_VERSION=v3.0.0
DOTFILES_REPO=kkb0318/dotfiles
XDG_CONFIG_HOME=$HOME/.config
XDG_DATA_HOME=$HOME/.local/share

os=$(uname -s | tr '[:upper:]' '[:lower:]')

# mkdir -p $XDG_CONFIG_HOME
# mkdir -p $XDG_DATA_HOME
# 
# 
# if [ "$os" = "linux" ] ; then
#   apt-get update
#   apt-get install -y curl
#   apt-get clean
#   rm -rf /var/lib/apt/lists/*
# fi
# 
# 
# # aqua
# curl -sSfL "https://raw.githubusercontent.com/aquaproj/aqua-installer/${AQUA_VERSION}/aqua-installer" | bash

export PATH="$XDG_DATA_HOME/aquaproj-aqua/bin:$PATH"

cd /tmp \
  && aqua init \
  && aqua g -i rhysd/dotfiles \
  && aqua g -i x-motemen/ghq \
  && aqua i -l \
  && ghq get $DOTFILES_REPO \
  && DOTFILES_DIR=$(ghq root)/$(ghq list | grep $DOTFILES_REPO) \
  && AQUA_GLOBAL_CONFIG_DIR=$DOTFILES_DIR/aqua \
  && AQUA_GLOBAL_CONFIG=$AQUA_GLOBAL_CONFIG_DIR/aqua.toml \
  && cd $AQUA_GLOBAL_CONFIG_DIR \
  && aqua install -l -a \
  && dotfiles link .



