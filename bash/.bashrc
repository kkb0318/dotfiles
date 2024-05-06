export BASH_SILENCE_DEPRECATION_WARNING=1

# PATH
export XDG_CONFIG_HOME="$HOME/.config"
export AQUA_ROOT_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/aquaproj-aqua"
export AQUA_BIN_PATH="${AQUA_ROOT_DIR}/bin"
export LOCALBIN="$HOME/.local/bin"
export HOMEBREW_X86_64_BIN="/usr/local/bin"
export HOMEBREW_ARM_BIN="/opt/homebrew/bin"
export CURLBIN="/usr/local/opt/curl/bin"

PATH=${HOMEBREW_ARM_BIN}:${HOMEBREW_X86_64_BIN}:${LOCALBIN}:/usr/bin:/bin:/opt/local/sbin:${PATH}
PATH=${AQUA_BIN_PATH}:${CURLBIN}:${PATH}

# aqua
export AQUA_GLOBAL_CONFIG=${AQUA_GLOBAL_CONFIG:-}:${XDG_CONFIG_HOME:-$HOME/.config}/aquaproj-aqua/aqua.yaml

