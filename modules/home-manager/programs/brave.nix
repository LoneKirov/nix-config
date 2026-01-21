{
  config,
  lib,
  pkgs,
  ...
}: {
  config = {
    # https://github.com/AvengeMedia/DankMaterialShell/issues/854
    home.packages = lib.optionals config.programs.dms-shell.enable [pkgs.adw-gtk3];
    programs.brave = {
      enable = lib.mkDefault config.services.xserver.enable;
      extensions = [];
      commandLineArgs = [];
    };
  };
}
