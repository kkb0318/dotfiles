#!/bin/bash

AQUA_VERSION=v3.0.0
DOTFILES_REPO=kkb0318/dotfiles
XDG_CONFIG_HOME=$HOME/.config
XDG_DATA_HOME=$HOME/.local/share

os=$(uname -s | tr '[:upper:]' '[:lower:]')

mkdir -p $XDG_CONFIG_HOME
mkdir -p $XDG_DATA_HOME


if [ "$os" = "linux" ] ; then
  apt-get update
  apt-get install -y curl
  apt-get clean
  rm -rf /var/lib/apt/lists/*
fi

curl -sSfL "https://raw.githubusercontent.com/aquaproj/aqua-installer/${AQUA_VERSION}/aqua-installer" | bash

export PATH="$XDG_DATA_HOME/aquaproj-aqua/bin:$PATH"
cd aqua \
  && aqua install -l -a \
  && cd ../ \
  && dotfiles link . 
