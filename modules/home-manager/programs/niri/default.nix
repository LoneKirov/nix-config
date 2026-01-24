{
  config,
  lib,
  ...
}: let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  inherit (config.xdg) configHome;
  niriConfig = "${configHome}/nix-config/modules/home-manager/programs/niri/config.kdl";
  dmsAltTabConfig = "${configHome}/nix-config/modules/home-manager/programs/niri/dms/alttab.kdl";
  dmsBindsConfig = "${configHome}/nix-config/modules/home-manager/programs/niri/dms/binds.kdl";
  dmsCursorConfig = "${configHome}/nix-config/modules/home-manager/programs/niri/dms/cursor.kdl";
  dmsLayoutConfig = "${configHome}/nix-config/modules/home-manager/programs/niri/dms/layout.kdl";
  dmsOutputsConfig = "${configHome}/nix-config/modules/home-manager/programs/niri/dms/outputs.kdl";
  dmsWpblurConfig = "${configHome}/nix-config/modules/home-manager/programs/niri/dms/wpblur.kdl";
in {
  config = lib.mkIf config.programs.niri.enable {
    xdg.configFile = {
      "niri/config.kdl".source = mkOutOfStoreSymlink niriConfig;
      "niri/dms/alttab.kdl".source = mkOutOfStoreSymlink dmsAltTabConfig;
      "niri/dms/binds.kdl".source = mkOutOfStoreSymlink dmsBindsConfig;
      "niri/dms/cursor.kdl".source = mkOutOfStoreSymlink dmsCursorConfig;
      "niri/dms/layout.kdl".source = mkOutOfStoreSymlink dmsLayoutConfig;
      "niri/dms/outputs.kdl".source = mkOutOfStoreSymlink dmsOutputsConfig;
      "niri/dms/wpblur.kdl".source = mkOutOfStoreSymlink dmsWpblurConfig;
    };
  };
}
