{
  imports = [ ../modules/common.nix ../modules/platforms/wsl.nix ../modules/work.nix ];
  # Set these to the actual Linux account before the first switch.
  home.username = "kkb";
  home.homeDirectory = "/home/kkb";
}
