{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.local.user.home-manager.local.programs.steam-flatpak.enable {
    hardware.steam-hardware.enable = true;

    # https://github.com/alsa-project/alsa-ucm-conf/issues/677#issuecomment-3755019801
    system.replaceDependencies.replacements = with pkgs; [
      {
        oldDependency = alsa-ucm-conf;
        newDependency = alsa-ucm-conf.overrideAttrs (oldAttrs: {
          patches = [
            ./alsa-ucm-dualsense-haptics.patch
          ];
          version = "1.2.15.3";
          src = fetchurl {
            url = "mirror://alsa/lib/alsa-ucm-conf-1.2.15.3.tar.bz2";
            hash = "sha256-n3noE8CPyGz6Rt11xPzaGkpRtILbJgfh/PqvuS9YijE=";
          };
        });
      }
    ];
  };
}
