{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  dms-shell = osConfig.programs.dms-shell.enable or false;
  xserver = osConfig.services.xserver.enable or false;
  brave = config.programs.brave.enable;
in {
  config = {
    programs.brave = {
      enable = lib.mkDefault xserver;
      extensions = [];
      commandLineArgs = [];
    };
    # https://github.com/AvengeMedia/DankMaterialShell/issues/854
    home.packages = lib.optionals (brave && dms-shell) [pkgs.adw-gtk3];
  };
}
