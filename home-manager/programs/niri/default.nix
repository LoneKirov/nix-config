{config, ...}: let
  mkOutOfStoreSymlink = config.lib.file.mkOutOfStoreSymlink;
  niriConfig = "/home/kirov/nix-config/home-manager/programs/niri/config.kdl";
  dmsAltTabConfig = "/home/kirov/nix-config/home-manager/programs/niri/dms/alttab.kdl";
  dmsBindsConfig = "/home/kirov/nix-config/home-manager/programs/niri/dms/binds.kdl";
  dmsColorsConfig = "/home/kirov/nix-config/home-manager/programs/niri/dms/colors.kdl";
  dmsLayoutConfig = "/home/kirov/nix-config/home-manager/programs/niri/dms/layout.kdl";
  dmsWpblurConfig = "/home/kirov/nix-config/home-manager/programs/niri/dms/wpblur.kdl";
in {
  config = {
    xdg.configFile = {
      "niri/config.kdl".source = mkOutOfStoreSymlink niriConfig;
      "niri/dms/alttab.kdl".source = mkOutOfStoreSymlink dmsAltTabConfig;
      "niri/dms/binds.kdl".source = mkOutOfStoreSymlink dmsBindsConfig;
      "niri/dms/colors.kdl".source = mkOutOfStoreSymlink dmsColorsConfig;
      "niri/dms/layout.kdl".source = mkOutOfStoreSymlink dmsLayoutConfig;
      "niri/dms/wpblur.kdl".source = mkOutOfStoreSymlink dmsWpblurConfig;
    };
  };
}
