# Capture the resolved location while sourcing; a later `cd` must not change it.
set -l __dotfiles_update_source (path resolve (status filename))
set -l __dotfiles_update_root (path resolve (path dirname "$__dotfiles_update_source")/../../..)

function update --inherit-variable __dotfiles_update_root --description "Apply reviewed, pinned package versions"
    argparse h/help n/dry-run -- $argv; or return 2
    if set -q _flag_help
        echo "Usage: update [--dry-run]"
        echo "Apply reviewed Fisher and Lazy pins. Use update-nix for packages. See docs/updates.md."
        return 0
    end
    if set -q argv[1]
        echo "update: unexpected arguments: $argv" >&2
        return 2
    end

    set -l repo_root "$__dotfiles_update_root"
    set -l failed_updates
    set -l skipped_updates
    set -l plugin_file "$repo_root/fish/fish_plugins"

    echo "Applying reviewed pins (version selection happens before this command)."

    # Fisher rewrites its active fish_plugins. Never accept a different file or
    # branches/tags that can move after review.
    if not type -q fisher
        set -a skipped_updates "Fisher: not installed"
    else if not test -s "$plugin_file"; or test (path resolve "$__fish_config_dir/fish_plugins") != (path resolve "$plugin_file")
        echo "Fisher: active fish_plugins must be linked to $plugin_file" >&2
        set -a failed_updates Fisher
    else
        set -l plugin_contents (string collect < "$plugin_file")
        set -l plugins
        set -l invalid_pins
        while read -l plugin
            if not string match -qr '^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+@[0-9a-f]{40}$' -- "$plugin"
                set -a invalid_pins "$plugin"
            else
                set -a plugins "$plugin"
            end
        end < "$plugin_file"

        if set -q invalid_pins[1]; or not set -q plugins[1]
            echo "Fisher: every entry must use a full commit SHA; refusing update" >&2
            set -a failed_updates Fisher
        else if set -q _flag_dry_run
            echo "[dry-run] fisher update using validated commit pins"
        else
            set -l needs_update false
            for plugin in $plugins
                contains -- "$plugin" $_fisher_plugins; or set needs_update true
            end
            test (count $plugins) -eq (count $_fisher_plugins); or set needs_update true

            if test "$needs_update" = true
                fisher update
                set -l fisher_status $status
                # Older Fisher can return success after failed downloads and
                # remove failed entries from this file. Preserve the manifest.
                printf '%s\n' "$plugin_contents" > "$plugin_file"; or set fisher_status 1
                for plugin in $plugins
                    contains -- "$plugin" $_fisher_plugins; or set fisher_status 1
                end
                test (count $plugins) -eq (count $_fisher_plugins); or set fisher_status 1
                if test $fisher_status -ne 0
                    set -a failed_updates Fisher
                else
                    echo "✅ Fisher pins applied"
                end
            else
                echo "✅ Fisher pins already applied"
            end
        end
    end

    if not command -q nvim
        set -a skipped_updates "Neovim: not installed"
    else if not test -s "$repo_root/nvim/lua/plugins/lazy-lock.json"
        echo "Neovim: reviewed lazy-lock.json is missing" >&2
        set -a failed_updates Neovim
    else if set -q _flag_dry_run
        echo "[dry-run] restore installed Lazy plugins from $repo_root/nvim/lua/plugins/lazy-lock.json"
    else
        begin
            set -lx DOTFILES_UPDATE_ROOT "$repo_root"
            if nvim --headless -u NONE -i NONE -n -l "$repo_root/nvim/scripts/restore-locked.lua"
                echo "✅ Lazy pins applied"
            else
                set -a failed_updates Neovim
            end
        end
    end

    echo "⏸ Held: Homebrew, Krew, Rustup/Cargo, Go, Volta, pyenv, SDKMAN and Mason."
    echo "  These need separately reviewed versions; see $repo_root/docs/updates.md."
    for item in $skipped_updates
        echo "⏭ $item"
    end
    if set -q failed_updates[1]
        printf '❌ Failed: %s\n' $failed_updates
        return 1
    end
    if set -q _flag_dry_run
        echo "✅ Dry run complete; nothing installed"
    else
        echo "✅ Selected pin applications completed (held/skipped items excluded)"
    end
    return 0
end
