{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}: {
  config = {
    home.packages = with pkgs; [
      swaybg # desktop background
    ];
    programs = {
      alacritty.enable = true; # terminal
      fuzzel.enable = true; # launcher
      swaylock.enable = true; # screen lock
      waybar.enable = true; # status bar
    };
    services = {
      mako.enable = true; # notification daemon
      swayidle.enable = true; # idle manager
      polkit-gnome.enable = true; # authentication agent
    };
  };
}
