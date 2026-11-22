{
  inputs,
  config,
  lib,
  ...
}: let
  inherit (lib) types;
  persistentMountpoint = "/persistent";
  isWSL = config.host.wsl;

  # Preservation's tmpfiles rules run on every boot after the bind mount is up,
  # so the ownership and mode in them override what the module that owns the
  # state sets through its own tmpfiles rule, createHome or StateDirectory. The
  # ":" prefix makes tmpfiles apply them only when it creates the path.
  withCreateOnly = key: mode: entry:
    {
      user = ":root";
      group = ":root";
      mode = ":${mode}";
    }
    // (
      if builtins.isString entry
      then {${key} = entry;}
      else entry
    );
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
        description = ''
          Directories to preserve under the persistent mountpoint. Unless an
          entry sets user, group or mode, a missing directory is created as
          root:root 0755 and an existing one keeps its ownership and mode.
        '';
      };
      files = lib.mkOption {
        type = types.listOf (types.either types.str types.attrs);
        default = [];
        description = ''
          Files to preserve under the persistent mountpoint. Unless an entry
          sets user, group or mode, a missing file is created as root:root 0644
          and an existing one keeps its ownership and mode.
        '';
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
            "/var/log"
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
          ]
          ++ lib.optionals config.services.postgresql.enable [
            "/var/lib/postgresql"
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
      # need /persistent available in initrd so preservation has access to it
      fileSystems.${persistentMountpoint}.neededForBoot = true;
      preservation.preserveAt.${persistentMountpoint} = {
        directories = map (withCreateOnly "directory" "0755") config.persist.directories;
        files = map (withCreateOnly "file" "0644") config.persist.files;
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
      # sops needs the host key during activation, which runs in the initrd, to
      # decrypt the user password. Persisting /etc/ssh would mean mounting it
      # before activation, which mixes activation's links into persistent state,
      # or after, which hides them, so the keys live in persistent storage instead.
      services.openssh.hostKeys = lib.mkDefault [
        {
          type = "rsa";
          bits = 4096;
          path = "${persistentMountpoint}/etc/ssh/ssh_host_rsa_key";
        }
        {
          type = "ed25519";
          path = "${persistentMountpoint}/etc/ssh/ssh_host_ed25519_key";
        }
      ];
    })
  ];
}
