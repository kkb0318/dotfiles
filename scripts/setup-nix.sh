#!/usr/bin/env bash
# No implicit lock update, channel lookup or unpinned Home Manager bootstrap.
set -euo pipefail
repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
usage() {
    echo "Usage: bash scripts/setup-nix.sh {work-mac|personal-mac|work-wsl|personal-wsl} [--build-only|--packages-only]"
}
if [[ ${1:-} == --help ]]; then usage; exit 0; fi
host=${1:-}
case "$host" in work-mac|personal-mac|work-wsl|personal-wsl) ;; *) usage >&2; exit 2 ;; esac
mode=${2:-}
case "$mode" in ''|--build-only|--packages-only) ;; *) usage >&2; exit 2 ;; esac
[[ $# -le 2 ]] || { usage >&2; exit 2; }
command -v nix >/dev/null || { echo "Install Nix with flakes enabled first." >&2; exit 1; }
# path: includes new module files even before they have been git-added.
flake="path:$repo/home-manager"
target="$flake#homeConfigurations.$host"
flags=(--no-write-lock-file --no-update-lock-file)
if [[ $mode != --build-only ]]; then
    expected_user=$(nix eval "${flags[@]}" --raw "$target.config.home.username")
    expected_home=$(nix eval "${flags[@]}" --raw "$target.config.home.homeDirectory")
    [[ $(id -un) == "$expected_user" && $HOME == "$expected_home" ]] || {
        echo "Edit home-manager/hosts/$host.nix for this account before applying ($expected_user / $expected_home)." >&2
        exit 1
    }
fi
scratch=$(mktemp -d)
trap 'rm -rf -- "$scratch"' EXIT
nix build "${flags[@]}" "$target.activationPackage" --out-link "$scratch/result"
echo "Built $host: $(readlink "$scratch/result")"
[[ $mode != --build-only ]] || exit 0
export PATH="$scratch/result/home-path/bin:$PATH"
# Check config collisions before activation. Never overwrite another setup.
if [[ $mode != --packages-only ]]; then
    python3 "$repo/scripts/bootstrap-plugins.py" --check
fi
"$scratch/result/activate"
state_dir=${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles
mkdir -p -- "$state_dir"
printf '%s\n' "$host" > "$state_dir/nix-host"
if [[ $mode != --packages-only ]]; then
    python3 "$repo/scripts/bootstrap-plugins.py"
    fish --no-config -c fish_update_completions
fi
echo "Applied $host from the existing lock. Open a new Fish session to use the Nix PATH."
