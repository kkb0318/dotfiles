export BASH_SILENCE_DEPRECATION_WARNING=1

# PATH
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export LOCALBIN="$HOME/.local/bin"
export HOMEBREW_X86_64_BIN="/usr/local/bin"
export HOMEBREW_ARM_BIN="/opt/homebrew/bin"
export HOMEBREW_LINUX_BIN="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin"
export CURLBIN="/usr/local/opt/curl/bin"

PATH=${HOMEBREW_ARM_BIN}:${HOMEBREW_X86_64_BIN}:${HOMEBREW_LINUX_BIN}:${LOCALBIN}:/usr/bin:/bin:/opt/local/sbin:${PATH}
PATH=${CURLBIN}:${PATH}

for profile in "$HOME/.nix-profile" "${XDG_STATE_HOME:-$HOME/.local/state}/nix/profiles/profile" "/etc/profiles/per-user/$(id -un)"; do
    if [ -d "$profile/bin" ]; then
        export PATH="$profile/bin:$PATH"
        break
    fi
done
