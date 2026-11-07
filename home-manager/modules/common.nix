{ pkgs, ... }:
{
  home.stateVersion = "25.05";
  # Keep Lazy/Fisher and the existing writable config directories in charge of
  # plugins. Do not also enable Home Manager's Neovim/Fish plugin management.
  home.packages = with pkgs; [
    go
    python313
    fish
    tmux
    neovim
    git
    curl # Fisher's pinned archive downloads
    gopls
    ruff
    # Required by existing Fish plugins and Neovim's picker.
    fzf
    ghq
    ripgrep
  ];
  programs.home-manager.enable = true;
  # Preserve the existing direnv setup and its hook in fish/config.fish.
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableBashIntegration = false;
    enableFishIntegration = false;
  };
}
