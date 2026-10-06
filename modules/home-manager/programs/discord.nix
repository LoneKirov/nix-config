{
  config,
  lib,
  pkgs,
  ...
}: let
  gui = config.host.gui;
in {
  options.programs.discord-flatpak.enable = lib.mkEnableOption "flatpak-discord" // {default = gui;};

  config = lib.mkIf config.programs.discord-flatpak.enable {
    home.packages = with pkgs; [xwayland-satellite];
    services.flatpak.packages = ["com.discordapp.Discord"];
  };
}
