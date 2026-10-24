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
  dms = osConfig.programs.dux-shell.enable or false;
in {
  config = lib.mkIf dms {
    xdg.configFile = {
      "dms/clsettings.json".source = mkOutOfStoreSymlink clsettings;
      "dms/settings.json".source = mkOutOfStoreSymlink settings;
    };
    home = {
      file.".face".source = mkOutOfStoreSymlink face;
      packages = [pkgs.dragon-drop];
    };
  };
}
