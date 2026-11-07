{ pkgs, ... }:
{
  assertions = [{
    assertion = pkgs.stdenv.isDarwin;
    message = "The darwin module requires a macOS system.";
  }];
}
