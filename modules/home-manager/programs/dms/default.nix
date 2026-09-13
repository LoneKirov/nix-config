{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  inherit (config.xdg) configHome;
  clsettings = "${configHome}/nix-config/modules/home-manager/programs/dms/clsettings.json";
  settings = "${configHome}/nix-config/modules/home-manager/programs/dms/settings.json";
  face = "${configHome}/nix-config/modules/home-manager/programs/dms/face.png";
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
