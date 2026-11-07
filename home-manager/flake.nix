{
  description = "Shared dotfiles with optional work/personal packages on macOS and WSL";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }:
    let
      mkHome = system: host:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { inherit system; };
          modules = [ host ];
        };
      configurations = {
        work-mac = mkHome "aarch64-darwin" ./hosts/work-mac.nix;
        personal-mac = mkHome "aarch64-darwin" ./hosts/personal-mac.nix;
        work-wsl = mkHome "x86_64-linux" ./hosts/work-wsl.nix;
        personal-wsl = mkHome "x86_64-linux" ./hosts/personal-wsl.nix;
      };
    in
    {
      # Keep the original entry point working during the migration.
      homeConfigurations = configurations // { kkb = configurations.personal-mac; };
      checks = {
        aarch64-darwin = {
          work = configurations.work-mac.activationPackage;
          personal = configurations.personal-mac.activationPackage;
        };
        x86_64-darwin = {
          work = (mkHome "x86_64-darwin" ./hosts/work-mac.nix).activationPackage;
          personal = (mkHome "x86_64-darwin" ./hosts/personal-mac.nix).activationPackage;
        };
        x86_64-linux = {
          work = configurations.work-wsl.activationPackage;
          personal = configurations.personal-wsl.activationPackage;
        };
      };
    };
}
