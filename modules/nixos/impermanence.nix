{
  config,
  lib,
  ...
}: let
  types = lib.types;
  persistentMountpoint = "/persistent";
in {
  options.impermanence.persistentMountpoint = lib.mkOption {
    type = types.str;
    default = persistentMountpoint;
    readOnly = true;
  };

  config = {
    # need /persistent available in initrd so preservation has access to it
    fileSystems.${persistentMountpoint}.neededForBoot = true;
    # Setup preservation to maintain state between wipes of /
    preservation = {
      enable = true;
      preserveAt.${persistentMountpoint} = {
        directories =
          [
            "/etc/nixos" # persist until user/github repo is setup
            {
              directory = "/var/lib/nixos"; # stores nixos state for generating stable uids and gids
              inInitrd = true; # make it available for nix in initrd
            }
            {
              directory = "/var/lib/systemd"; # coredump store
              inInitrd = true; # make it available for systemd in initrd
            }
            {
              directory = "/var/log"; # system logs
              inInitrd = true; # make it available for journald in initrd
            }
          ]
          ++ lib.optionals config.boot.lanzaboote.enable [
            {
              directory = "/etc/secureboot"; # persist secureboot config
              inInitrd = true; # making it available early just in case
            }
            "/var/lib/sbctl" # persist secureboot keys managed by sbctl
          ]
          ++ lib.optionals config.networking.networkmanager.enable [
            "/etc/NetworkManager/system-connections" # NM connections
          ]
          ++ lib.optionals config.services.fprintd.enable [
            "/var/lib/fprint" # fingerprint store
          ]
          ++ lib.optionals config.services.fwupd.enable [
            "/var/lib/fwupd" # firmware update store
          ]
          ++ lib.optionals config.services.upower.enable [
            "/var/lib/upower" # power statistics and history
          ];
        files = [
          {
            # machine id. needs to be available early in boot
            file = "/etc/machine-id";
            how = "symlink";
            inInitrd = true;
            configureParent = true;
            createLinkTarget = true;
          }
        ];
      };
    };
    # https://github.com/nix-community/preservation/issues/22
    boot.initrd.systemd.tmpfiles.settings.preservation."/sysroot${persistentMountpoint}/etc/machine-id".f = {
      argument = "uninitialized";
    };
    # user mutations won't persist across reboots
    users.mutableUsers = false;
  };
}
