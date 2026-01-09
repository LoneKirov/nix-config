{
  config,
  osConfig,
  lib,
  pkgs,
  ...
}: {
  options.programs.discord-flatpak.enable = lib.mkEnableOption "discord-flatpak";

  config = lib.mkMerge [
    {programs.discord-flatpak.enable = lib.mkDefault osConfig.services.xserver.enable;}
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
