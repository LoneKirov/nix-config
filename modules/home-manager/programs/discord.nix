{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  gui = osConfig.host.gui or false;
in {
  options.programs.discord-flatpak.enable = lib.mkEnableOption "flatpak-discord";

  config = lib.mkMerge [
    {programs.discord-flatpak.enable = lib.mkDefault gui;}
    (lib.mkIf config.programs.discord-flatpak.enable {
      home.packages = with pkgs; [xwayland-satellite];
      services.flatpak.packages = ["com.discordapp.Discord"];
    })
  ];
}
