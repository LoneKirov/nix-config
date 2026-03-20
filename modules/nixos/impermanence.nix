{
  inputs,
  config,
  lib,
  ...
}: let
  types = lib.types;
  persistentMountpoint = "/persistent";
in {
  imports = [
    inputs.preservation.nixosModules.preservation
  ];

  options.local.impermanence.persistentMountpoint = lib.mkOption {
    type = types.str;
    default = persistentMountpoint;
    readOnly = true;
  };

  config = {
    # Enable systemd within initrd
    boot.initrd.systemd.enable = true;
    # need /persistent available in initrd so preservation has access to it
    fileSystems.${persistentMountpoint}.neededForBoot = true;
    # Setup preservation to maintain state between wipes of /
    preservation = {
      enable = true;
      preserveAt.${persistentMountpoint} = {
        directories =
          [
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
            {
              directory = "/etc/ssh"; # ssh host keys
              inInitrd = true; # make it available for sops in initrd
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
          ]
          ++ lib.optionals config.services.tailscale.enable [
            "/var/lib/tailscale" # tailscale state
          ]
          ++ lib.optionals config.virtualisation.quadlet.enable [
            "/var/lib/containers" # podman storage
          ]
          ++ lib.optionals config.hardware.bluetooth.enable [
            "/var/lib/bluetooth" # bluetooth store
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
