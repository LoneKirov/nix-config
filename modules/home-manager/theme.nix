{
  lib,
  osConfig,
  pkgs,
  ...
}: let
  dms-shell = osConfig.programs.dms-shell.enable or false;
in {
  config = lib.mkIf dms-shell {
    gtk = {
      enable = true;
      theme = {
        name = "adw-gtk3";
        package = pkgs.adw-gtk3;
      };
      iconTheme = {
        name = "Papirus";
        package = pkgs.papirus-icon-theme;
      };
    };
  };
}
