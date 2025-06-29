function update --description "Update all package managers and their packages"
    set -l failed_updates

    echo "🔄 Starting comprehensive system update..."
    echo ""

    # Homebrew
    echo "📦 Updating Homebrew..."
    if brew update && brew upgrade
        echo "✅ Homebrew updated successfully"
    else
        set -a failed_updates "Homebrew"
    end
    echo ""

    # Aqua
    if command -q aqua
        echo "💧 Updating Aqua packages..."
        if aqua update
            echo "✅ Aqua updated successfully"
        else
            set -a failed_updates "Aqua"
        end
        echo ""
    end

    # Fisher
    echo "🐟 Updating Fish plugins..."
    if fisher update
        echo "✅ Fisher updated successfully"
    else
        set -a failed_updates "Fisher"
    end
    echo ""

    # Kubectl Krew
    if command -q kubectl && kubectl krew version &>/dev/null
        echo "☸️  Updating kubectl plugins..."
        if kubectl krew upgrade
            echo "✅ Kubectl Krew updated successfully"
        else
            set -a failed_updates "Kubectl Krew"
        end
        echo ""
    end

    # Rust/Cargo
    if command -q rustup
        echo "🦀 Updating Rust toolchain..."
        if rustup update
            echo "✅ Rustup updated successfully"
        else
            set -a failed_updates "Rustup"
        end
        
        # Update cargo-installed binaries
        if command -q cargo-update
            echo "📦 Updating Cargo packages..."
            if cargo install-update -a
                echo "✅ Cargo packages updated successfully"
            else
                set -a failed_updates "Cargo packages"
            end
        else
            echo "💡 Tip: Install cargo-update with 'cargo install cargo-update' to update cargo packages"
        end
        echo ""
    end

    # Go packages
    if command -q go
        echo "🐹 Updating Go packages..."
        set -l go_bin_path (go env GOPATH)/bin
        if test -d $go_bin_path
            for tool in (ls $go_bin_path)
                if go install (go version -m $go_bin_path/$tool | grep "^\s*path" | awk '{print $2}')@latest &>/dev/null
                    echo "  ✅ Updated: $tool"
                else
                    echo "  ⚠️  Failed to update: $tool"
                end
            end
        end
        echo ""
    end

    # Node.js (via Volta)
    if command -q volta
        echo "⚡ Updating Node.js via Volta..."
        if volta install node@lts
            echo "✅ Node.js LTS updated successfully"
        else
            set -a failed_updates "Node.js (Volta)"
        end
        echo ""
    end

    # Python (via pyenv)
    if command -q pyenv
        echo "🐍 Checking Python updates..."
        if command -q pyenv-update
            if pyenv update
                echo "✅ Pyenv updated successfully"
            else
                set -a failed_updates "Pyenv"
            end
        else
            echo "💡 Tip: Install pyenv-update plugin to update pyenv"
        end
        echo ""
    end

    # SDKMAN!
    if test -f "$HOME/.sdkman/bin/sdkman-init.sh"
        echo "☕ Updating SDKMAN! packages..."
        bash -c "source $HOME/.sdkman/bin/sdkman-init.sh && sdk update && sdk upgrade"
        echo ""
    end

    # Neovim packages
    if command -q nvim
        echo "📝 Updating Neovim packages..."
        echo "  Updating Lazy plugins..."
        nvim --headless "+Lazy! sync" +qa
        echo "  Updating Mason packages..."
        nvim --headless "+MasonUpdate" +qa
        echo "✅ Neovim packages updated"
        echo ""
    end

    # Summary
    echo "📊 Update Summary:"
    if test (count $failed_updates) -eq 0
        echo "✅ All updates completed successfully!"
    else
        echo "⚠️  The following updates failed:"
        for item in $failed_updates
            echo "  - $item"
        end
    end
end