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
    home = {
      sessionVariables = {
        QT_QPA_PLATFORMTHEME = "gtk3";
        QT_QPA_PLATFORMTHEME_QT6 = "gtk3";
      };
      packages = with pkgs; [
        adw-gtk3
      ];
    };
  };
}
