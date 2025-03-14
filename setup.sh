#!/bin/bash

AQUA_VERSION=v3.0.1
XDG_CONFIG_HOME=$HOME/.config
XDG_DATA_HOME=$HOME/.local/share

os=$(uname -s | tr '[:upper:]' '[:lower:]')

mkdir -p $XDG_CONFIG_HOME
mkdir -p $XDG_DATA_HOME

if [ "$os" = "darwin" ] ; then
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
  
  brew install fish curl neovim
  # set default shell
  echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
  chsh -s /opt/homebrew/bin/fish

fi

if [ "$os" = "linux" ] ; then
 if command -v lsb_release >/dev/null 2>&1; then
  distro=$(lsb_release -is)
 else
  distro=$(cat /etc/os-release | grep ^ID= | cut -d'=' -f2 | tr -d '"')
 fi

 case "$distro" in
  Ubuntu|Debian)
   apt-get update
   apt-get install -y curl fish
   apt-get clean
   rm -rf /var/lib/apt/lists/*
   ;;
  centos|rhel|fedora)
   yum install -y curl fish
   ;;
  amzn)
   amazon-linux-extras install -y epel
   yum install -y curl
   cd /etc/yum.repos.d/
   wget https://download.opensuse.org/repositories/shells:fish:release:3/CentOS_7/shells:fish:release:3.repo
   yum install -y fish
   ;;
  *)
   echo "Unsupported Linux distribution: $distro"
   exit 1
   ;;
 esac
fi

# install aqua
curl -sSfL -O https://raw.githubusercontent.com/aquaproj/aqua-installer/${AQUA_VERSION}/aqua-installer
echo "fb4b3b7d026e5aba1fc478c268e8fbd653e01404c8a8c6284fdba88ae62eda6a  aqua-installer" | sha256sum -c
chmod +x aqua-installer
./aqua-installer

export PATH=${AQUA_ROOT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/aquaproj-aqua}/bin:$PATH
cd aqua \
  && aqua install -l -a \
  && cd ../ \
  && dotfiles link . 


# fish shell
fish -c "curl -sL https://git.io/fisher | source && fisher update"
fish -c "fish_update_completions"

