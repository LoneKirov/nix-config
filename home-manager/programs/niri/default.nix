{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}: {
  config = {
    programs = {
      alacritty.enable = true; # terminal
    };
  };
}
