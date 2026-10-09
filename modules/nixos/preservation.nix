{
  inputs,
  config,
  lib,
  ...
}: let
  inherit (lib) types;
  persistentMountpoint = "/persistent";
  isWSL = config.host.wsl;
in {
  imports = [
    inputs.preservation.nixosModules.preservation
  ];

  options = {
    # modules persist their own state through these; they're a no-op when preservation is disabled
    persist = {
      mountpoint = lib.mkOption {
        type = types.str;
        default = persistentMountpoint;
        readOnly = true;
        description = "Where persistent state lives.";
      };
      directories = lib.mkOption {
        type = types.listOf (types.either types.str types.attrs);
        default = [];
        description = "Directories to preserve under the persistent mountpoint.";
      };
      files = lib.mkOption {
        type = types.listOf (types.either types.str types.attrs);
        default = [];
        description = "Files to preserve under the persistent mountpoint.";
      };
    };
  };

  config = lib.mkMerge [
    {
      preservation.enable = lib.mkDefault (! isWSL);

      # state from NixOS itself and from services this repo doesn't enable directly
      persist = {
        directories =
          [
            {
              directory = "/var/lib/nixos"; # stores nixos state for generating stable uids and gids
              inInitrd = true; # make it available for nix in initrd
            }
            {
              directory = "/var/lib/systemd";
              inInitrd = true; # make it available for systemd in initrd
            }
            {
              directory = "/var/log";
              inInitrd = true; # make it available for journald in initrd
            }
            {
              directory = "/etc/ssh"; # ssh host keys
              inInitrd = true; # make it available for sops in initrd
            }
          ]
          ++ lib.optionals config.services.fprintd.enable [
            "/var/lib/fprint"
          ]
          ++ lib.optionals config.services.upower.enable [
            "/var/lib/upower"
          ]
          ++ lib.optionals config.hardware.bluetooth.enable [
            "/var/lib/bluetooth"
          ]
          ++ lib.optionals config.services.accounts-daemon.enable [
            "/var/lib/AccountsService"
          ];
        files = [
          {
            # machine id. needs to be available early in boot
            file = "/etc/machine-id";
            inInitrd = true;
          }
        ];
      };
    }
    (lib.mkIf config.preservation.enable {
      # preservation requires a systemd initrd
      boot.initrd.systemd.enable = true;
      # need /persistent available in initrd so preservation has access to it
      fileSystems.${persistentMountpoint}.neededForBoot = true;
      preservation.preserveAt.${persistentMountpoint} = {
        inherit (config.persist) directories files;
      };
      # setup /var/lib/private for persisting DynamicUser services
      systemd.tmpfiles.rules = [
        "d /var/lib/private 0700 root root"
      ];
      # https://github.com/nix-community/preservation/issues/22
      boot.initrd.systemd.tmpfiles.settings.preservation."/sysroot${persistentMountpoint}/etc/machine-id".f = {
        argument = "uninitialized";
      };
      systemd.services.systemd-machine-id-commit.unitConfig.ConditionFirstBoot = true;
      # user mutations won't persist across reboots
      users.mutableUsers = false;
    })
  ];
}
