{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  xserver = osConfig.services.xserver.enable or false;
in {
  options.programs.discord-flatpak.enable = lib.mkEnableOption "flatpak-discord";

  config = lib.mkMerge [
    {programs.discord-flatpak.enable = lib.mkDefault xserver;}
    (lib.mkIf config.programs.discord-flatpak.enable {
      home.packages = with pkgs; [xwayland-satellite];
      services.flatpak.packages = ["com.discordapp.Discord"];
    })
  ];
}
