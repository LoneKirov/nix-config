{
  config,
  lib,
  osConfig,
  ...
}: let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  dir = "${osConfig.user.flakeCheckout}/modules/home-manager/programs/niri";
  niriConfig = "${dir}/config.kdl";
  dmsAltTabConfig = "${dir}/dms/alttab.kdl";
  dmsBindsConfig = "${dir}/dms/binds.kdl";
  dmsCursorConfig = "${dir}/dms/cursor.kdl";
  dmsInputConfig = "${dir}/dms/input.kdl";
  dmsLayoutConfig = "${dir}/dms/layout.kdl";
  dmsOutputsConfig = "${dir}/dms/outputs.kdl";
  dmsWpblurConfig = "${dir}/dms/wpblur.kdl";
  dmsWindowrulesConfig = "${dir}/dms/windowrules.kdl";
  niri = osConfig.programs.niri.enable or false;
in {
  config = lib.mkIf niri {
    xdg.configFile = {
      "niri/config.kdl".source = mkOutOfStoreSymlink niriConfig;
      "niri/dms/alttab.kdl".source = mkOutOfStoreSymlink dmsAltTabConfig;
      "niri/dms/binds.kdl".source = mkOutOfStoreSymlink dmsBindsConfig;
      "niri/dms/cursor.kdl".source = mkOutOfStoreSymlink dmsCursorConfig;
      "niri/dms/input.kdl".source = mkOutOfStoreSymlink dmsInputConfig;
      "niri/dms/layout.kdl".source = mkOutOfStoreSymlink dmsLayoutConfig;
      "niri/dms/outputs.kdl".source = mkOutOfStoreSymlink dmsOutputsConfig;
      "niri/dms/wpblur.kdl".source = mkOutOfStoreSymlink dmsWpblurConfig;
      "niri/dms/windowrules.kdl".source = mkOutOfStoreSymlink dmsWindowrulesConfig;
    };
  };
}
