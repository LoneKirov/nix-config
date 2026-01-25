{
  lib,
  pkgs,
  ...
}: {
  home-manager.users.kirov.programs.vicinae.baseSettings.providers = {
    "@fearoffish/store.raycast.kagi-search".preferences = {
      fastGptShortcut = false;
      useApiForSearch = false;
    };
    "@tonka3000/store.raycast.homeassistant".preferences.instance = "https://homeassistant.kanto.casa/";
    "@jomifepe/store.raycast.bitwarden".preferences.cliPath = lib.getExe' pkgs.bitwarden-cli "bw";
  };
}
