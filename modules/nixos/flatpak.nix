{
  config,
  lib,
  ...
}: let
  hmUsers = lib.attrsToList config.home-manager.users;
  isFlatpakEnabled = user: r: r || user.value.services.flatpak.enable;
in {
  # enable flatpak on the system level if a home-manager user needs it
  services.flatpak.enable = lib.foldr isFlatpakEnabled false hmUsers;
}
