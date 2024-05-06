#!/bin/bash

AQUA_VERSION=v3.0.0
XDG_CONFIG_HOME=$HOME/.config
XDG_DATA_HOME=$HOME/.local/share

os=$(uname -s | tr '[:upper:]' '[:lower:]')

mkdir -p $XDG_CONFIG_HOME
mkdir -p $XDG_DATA_HOME

if [ os == "darwin" ] ; then
  if ! xcode-select -p > /dev/null 2>&1 ; then
    xcode-select --install
  fi
  softwareupdate --install-rosetta --agree-to-license
  export SDKROOT=$(xcrun --sdk macosx --show-sdk-path)

  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
  defaults write -g AppleShowAllExtensions -bool true

  defaults write com.apple.dock autohide -bool true
  defaults write com.apple.dock show-recents -bool false
  killall Dock

  defaults write com.apple.finder AppleShowAllFiles -bool true
  defaults write com.apple.finder ShowPathbar -bool true
  defaults write com.apple.finder ShowStatusBar -bool true
  defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
  defaults write com.apple.finder "FXPreferredViewStyle" -string "Nlsv" # List View
  defaults write com.apple.finder "_FXSortFoldersFirst" -bool true
  defaults write NSGlobalDomain "NSToolbarTitleViewRolloverDelay" -float 0 # ツールバータイトルビューにマウスカーソルを合わせたときの遅延
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true # ファイルの拡張子を常に表示
  killall Finder
  # install homebrew
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  source ./bash/.bashrc
  
  brew install fish curl

fi


if [ "$os" = "linux" ] ; then
  apt-get update
  apt-get install -y curl
  apt-get clean
  apt-get install fish
  rm -rf /var/lib/apt/lists/*
fi

curl -sSfL "https://raw.githubusercontent.com/aquaproj/aqua-installer/${AQUA_VERSION}/aqua-installer" | bash

export PATH="$XDG_DATA_HOME/aquaproj-aqua/bin:$PATH"
cd aqua \
  && aqua install -l -a \
  && cd ../ \
  && dotfiles link . 


# fish shell
fish -c "curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher"
fish -c "fisher update"
fish -c "fish_update_completions"

