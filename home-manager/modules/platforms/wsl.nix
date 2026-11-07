{ pkgs, ... }:
{
  assertions = [{
    assertion = pkgs.stdenv.isLinux;
    message = "The WSL module requires a Linux system.";
  }];
  # Windows host applications and WSL installation are outside this profile.
}
