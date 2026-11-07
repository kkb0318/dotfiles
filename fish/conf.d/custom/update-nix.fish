set -l __dotfiles_nix_source (path resolve (status filename))
set -l __dotfiles_nix_root (path resolve (path dirname "$__dotfiles_nix_source")/../../..)

function update-nix --inherit-variable __dotfiles_nix_root --description "Apply the existing Nix lock for this host"
    argparse h/help b/build-only -- $argv; or return 2
    if set -q _flag_help
        echo "Usage: update-nix [work-mac|personal-mac|work-wsl|personal-wsl] [--build-only]"
        echo "Applies the existing lock; does not select new versions or restore plugins."
        return 0
    end
    if test (count $argv) -gt 1
        echo "update-nix: expected at most one host name" >&2
        return 2
    end
    set -l host $argv[1]
    if not set -q host[1]
        set -l state_home "$HOME/.local/state"
        set -q XDG_STATE_HOME; and set state_home "$XDG_STATE_HOME"
        if test -r "$state_home/dotfiles/nix-host"
            read host < "$state_home/dotfiles/nix-host"
        end
    end
    if not contains -- "$host" work-mac personal-mac work-wsl personal-wsl
        echo "update-nix: select a host explicitly on the first run (see --help)" >&2
        return 2
    end
    set -l mode --packages-only
    set -q _flag_build_only; and set mode --build-only
    command bash "$__dotfiles_nix_root/scripts/setup-nix.sh" "$host" "$mode"
end
