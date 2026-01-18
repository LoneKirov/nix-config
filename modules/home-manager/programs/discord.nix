{
  config,
  osConfig,
  lib,
  pkgs,
  ...
}: let
  osConfig' = lib.attrsets.optionalAttrs (!isNull osConfig) osConfig;
  xserverEnabled = lib.attrsets.attrByPath ["services" "xserver" "enable"] false osConfig';
in {
  options.programs.discord-flatpak.enable = lib.mkEnableOption "discord-flatpak";

  config = lib.mkMerge [
    {programs.discord-flatpak.enable = lib.mkDefault xserverEnabled;}
    (lib.mkIf config.programs.discord-flatpak.enable {
      home.packages = with pkgs; [xwayland-satellite];
      services.flatpak = {
        enable = true;
        packages = ["com.discordapp.Discord"];
        update.auto.enable = true;
      };
      # https://github.com/gmodena/nix-flatpak/issues/31
      xdg.systemDirs.data = ["$HOME/.local/share/flatpak/exports/share"];
    })
  ];
}
