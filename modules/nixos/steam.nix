{
  config,
  lib,
  ...
}: let
  inherit (config.user) username;
  home-manager = config.home-manager.users.${username};
  steam-flatpak = home-manager.programs.steam-flatpak.enable;
in {
  config = lib.mkIf steam-flatpak {
    hardware.steam-hardware.enable = true;
  };
}
