{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.programs.dms-shell.enable {
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
