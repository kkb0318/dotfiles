{ pkgs, ... }:
{
  assertions = [{
    assertion = pkgs.stdenv.isDarwin;
    message = "The darwin module requires a macOS system.";
  }];
  # User preferences previously applied by the legacy setup script.
  # Restart Finder/Dock or log in again after activation to see all changes.
  targets.darwin.defaults = {
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      NSToolbarTitleViewRolloverDelay = 0;
    };
    "com.apple.desktopservices".DSDontWriteNetworkStores = true;
    "com.apple.dock" = {
      autohide = true;
      show-recents = false;
    };
    "com.apple.finder" = {
      AppleShowAllFiles = true;
      ShowPathbar = true;
      ShowStatusBar = true;
      FXEnableExtensionChangeWarning = false;
      FXPreferredViewStyle = "Nlsv";
      _FXSortFoldersFirst = true;
    };
  };
}
