{
  config,
  lib,
  pkgs,
  ...
}: {
  options.local.programs.discord-flatpak.enable = lib.mkEnableOption "discord-flatpak";

  config = lib.mkMerge [
    {local.programs.discord-flatpak.enable = lib.mkDefault config.services.xserver.enable;}
    (lib.mkIf config.local.programs.discord-flatpak.enable {
      home.packages = with pkgs; [xwayland-satellite];
      services.flatpak.packages = ["com.discordapp.Discord"];
    })
  ];
}
