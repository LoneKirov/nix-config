{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  dir = "${osConfig.user.flakeCheckout}/modules/home-manager/programs/dms";
  clsettings = "${dir}/clsettings.json";
  settings = "${dir}/settings.json";
  face = "${dir}/face.png";
  dms = osConfig.programs.dms-shell.enable or false;
in {
  config = lib.mkIf dms {
    xdg.configFile = {
      "DankMaterialShell/clsettings.json".source = mkOutOfStoreSymlink clsettings;
      "DankMaterialShell/settings.json".source = mkOutOfStoreSymlink settings;
    };
    home = {
      file.".face".source = mkOutOfStoreSymlink face;
      packages = [pkgs.dragon-drop];
    };
  };
}
