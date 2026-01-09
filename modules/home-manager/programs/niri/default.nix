{
  config,
  osConfig,
  lib,
  ...
}: let
  xdgConfigHome = config.xdg.configHome;
  mkOutOfStoreSymlink = config.lib.file.mkOutOfStoreSymlink;
  niriConfig = "${xdgConfigHome}/nix-config/modules/home-manager/programs/niri/config.kdl";
  dmsAltTabConfig = "${xdgConfigHome}/nix-config/modules/home-manager/programs/niri/dms/alttab.kdl";
  dmsBindsConfig = "${xdgConfigHome}/nix-config/modules/home-manager/programs/niri/dms/binds.kdl";
  dmsColorsConfig = "${xdgConfigHome}/nix-config/modules/home-manager/programs/niri/dms/colors.kdl";
  dmsLayoutConfig = "${xdgConfigHome}/nix-config/modules/home-manager/programs/niri/dms/layout.kdl";
  dmsWpblurConfig = "${xdgConfigHome}/nix-config/modules/home-manager/programs/niri/dms/wpblur.kdl";
in {
  config = {
    xdg.configFile = lib.mkIf osConfig.programs.niri.enable {
      "niri/config.kdl".source = mkOutOfStoreSymlink niriConfig;
      "niri/dms/alttab.kdl".source = mkOutOfStoreSymlink dmsAltTabConfig;
      "niri/dms/binds.kdl".source = mkOutOfStoreSymlink dmsBindsConfig;
      "niri/dms/colors.kdl".source = mkOutOfStoreSymlink dmsColorsConfig;
      "niri/dms/layout.kdl".source = mkOutOfStoreSymlink dmsLayoutConfig;
      "niri/dms/wpblur.kdl".source = mkOutOfStoreSymlink dmsWpblurConfig;
    };
  };
}
