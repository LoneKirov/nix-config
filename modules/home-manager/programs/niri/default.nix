{
  config,
  osConfig,
  lib,
  ...
}: let
  osConfig' = lib.attrsets.optionalAttrs (!isNull osConfig) osConfig;
  niriEnabled = lib.attrsets.attrByPath ["programs" "niri" "enable"] false osConfig';
  xdgConfigHome = config.xdg.configHome;
  mkOutOfStoreSymlink = config.lib.file.mkOutOfStoreSymlink;
  niriConfig = "${xdgConfigHome}/nix-config/modules/home-manager/programs/niri/config.kdl";
  dmsAltTabConfig = "${xdgConfigHome}/nix-config/modules/home-manager/programs/niri/dms/alttab.kdl";
  dmsBindsConfig = "${xdgConfigHome}/nix-config/modules/home-manager/programs/niri/dms/binds.kdl";
  dmsColorsConfig = "${xdgConfigHome}/nix-config/modules/home-manager/programs/niri/dms/colors.kdl";
  dmsCursorConfig = "${xdgConfigHome}/nix-config/modules/home-manager/programs/niri/dms/cursor.kdl";
  dmsLayoutConfig = "${xdgConfigHome}/nix-config/modules/home-manager/programs/niri/dms/layout.kdl";
  dmsOutputsConfig = "${xdgConfigHome}/nix-config/modules/home-manager/programs/niri/dms/outputs.kdl";
  dmsWpblurConfig = "${xdgConfigHome}/nix-config/modules/home-manager/programs/niri/dms/wpblur.kdl";
in {
  config = lib.mkIf niriEnabled {
    xdg.configFile = {
      "niri/config.kdl".source = mkOutOfStoreSymlink niriConfig;
      "niri/dms/alttab.kdl".source = mkOutOfStoreSymlink dmsAltTabConfig;
      "niri/dms/binds.kdl".source = mkOutOfStoreSymlink dmsBindsConfig;
      "niri/dms/colors.kdl".source = mkOutOfStoreSymlink dmsColorsConfig;
      "niri/dms/cursor.kdl".source = mkOutOfStoreSymlink dmsCursorConfig;
      "niri/dms/layout.kdl".source = mkOutOfStoreSymlink dmsLayoutConfig;
      "niri/dms/outputs.kdl".source = mkOutOfStoreSymlink dmsOutputsConfig;
      "niri/dms/wpblur.kdl".source = mkOutOfStoreSymlink dmsWpblurConfig;
    };
  };
}
