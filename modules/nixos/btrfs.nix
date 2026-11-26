{
  config,
  lib,
  pkgs,
  ...
}: let
  hasBtrfs = lib.any (fs: fs.fsType == "btrfs") (lib.attrValues config.fileSystems);
  inherit (config.networking) hostName;
  inherit (config.host.backup) targets receive;
  # each target confines this host's key to its own directory
  targetsFor = subvolume:
    lib.listToAttrs (map (target:
      lib.nameValuePair "ssh://${target}${config.hosts.${target}.backup.receive}/${hostName}/${subvolume}" {})
    targets);
in {
  options.btrbk = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Snapshots /home and the persistent subvolume hourly with btrbk, sending them on to `host.backup.targets`.";
    };
    sshKeySopsFile = lib.mkOption {
      type = lib.types.path;
      description = "Sops file holding this host's btrbk ssh key under the `ssh_key` key; required when `host.backup.targets` is set.";
    };
  };

  config = lib.mkIf hasBtrfs (lib.mkMerge [
    {
      services = {
        btrfs.autoScrub.enable = lib.mkDefault true;
        btrbk.extraPackages = [pkgs.lz4];
      };
      systemd = {
        # raid1 rewrites a bad copy from the good one without failing anything,
        # and scrub only fails on errors it couldn't repair, so these counters
        # can be the only sign of a failing disk. They persist across reboots,
        # so this keeps failing until they're cleared with `btrfs device stats -z`
        services.btrfs-device-stats = {
          description = "Check btrfs device error counters";
          path = [pkgs.btrfs-progs pkgs.util-linux];
          script = ''
            status=0
            # one mount per filesystem, since its subvolume mounts share a UUID
            for mountpoint in $(findmnt -t btrfs -nro UUID,TARGET | sort -u -k1,1 | cut -d' ' -f2); do
              btrfs device stats --check "$mountpoint" || status=1
            done
            exit $status
          '';
          serviceConfig.Type = "oneshot";
          startAt = "daily";
        };
        timers.btrfs-device-stats.timerConfig.Persistent = true;

        # btrfs-scrub@ cancels its scrub when stopped, and its timer has already
        # fired, so an upgrade's reboot would drop that scrub until the next
        # interval. A balance needs no check, since it resumes on the next mount.
        # Exiting 1 skips this run without failing it
        services.nixos-upgrade = lib.mkIf config.system.autoUpgrade.enable {
          serviceConfig.ExecCondition = lib.getExe (pkgs.writeShellApplication {
            name = "no-btrfs-scrub-running";
            runtimeInputs = [pkgs.btrfs-progs pkgs.util-linux];
            text = ''
              for mountpoint in $(findmnt -t btrfs -nro UUID,TARGET | sort -u -k1,1 | cut -d' ' -f2); do
                if [[ $(btrfs scrub status "$mountpoint") =~ Status:\ +running ]]; then
                  echo "btrfs scrub running on $mountpoint, skipping this upgrade"
                  exit 1
                fi
              done
            '';
          });
        };

        # Once unallocated space runs low (10 GiB on any filesystem bigger than
        # that), the kernel moves data out of its emptiest block groups, more
        # eagerly the closer it gets to none, so metadata can still get new
        # chunks without a regular balance. The threshold is sized from data
        # chunks, so metadata is left alone
        # https://btrfs.readthedocs.io/en/latest/ch-sysfs.html
        tmpfiles.settings.btrfs-reclaim = {
          "/sys/fs/btrfs/*/allocation/data/dynamic_reclaim".w.argument = "1";
          "/sys/fs/btrfs/*/allocation/data/periodic_reclaim".w.argument = "1";
        };
      };
    }
    (lib.mkIf (config.services.beesd.filesystems != {}) {
      # bees 0.11 caps a match at 128 MiB, but btrfs preallocates extents of up
      # to 256 MiB. In a duplicate extent longer than 128 MiB, every block past
      # the cap starts a new match that walks 128 MiB back, a few seconds per
      # block, so one file can hold a core for hours. The beesd module has no
      # package option, hence the overlay
      # https://github.com/Zygo/bees/issues/325
      nixpkgs.overlays = [
        (final: prev: {
          bees = prev.bees.overrideAttrs (old: {
            patches =
              (old.patches or [])
              ++ [
                (final.fetchpatch {
                  url = "https://github.com/Zygo/bees/commit/b8086fb41af052bdadf35dc13382604e246dc12c.patch";
                  hash = "sha256-HhK0swaw9zfz4uoKSNq3nhQrs/UzmJ/GH0Yg9KLrW54=";
                })
              ];
          });
        })
      ];
    })
    (lib.mkIf config.btrbk.enable {
      services.btrbk.instances.btrbk = {
        onCalendar = "hourly";
        settings = {
          ssh_user = "btrbk";
          snapshot_create = "onchange";
          # local snapshots are for quick undo; longer history lives on the targets
          snapshot_preserve = "24h 14d";
          snapshot_preserve_min = "1h";
          target_preserve = "24h 14d 12w 12m";
          target_preserve_min = "1h";
          stream_compress = "lz4";
          subvolume."/home" = {
            snapshot_dir = "/home/.snapshots";
          };
          subvolume."${config.persist.mountpoint}" = {
            snapshot_dir = "${config.persist.mountpoint}/.snapshots";
          };
        };
      };
      systemd.services.btrbk-btrbk = {
        wants = ["network-online.target"];
        after = ["network-online.target"];
        # the timer catches up right after resume, before DNS is back (see
        # tailscale-restart-on-resume), so retry rather than wait an hour. A
        # run whose target fails skips snapshot cleanup, so retrying until the
        # target is back would pile up snapshots while offline
        serviceConfig = {
          Restart = "on-failure";
          RestartSec = "2min";
        };
        startLimitBurst = 3;
        startLimitIntervalSec = 15 * 60;
      };
      notify.healthchecks.btrbk-btrbk = "btrbk";
    })
    (lib.mkIf (targets != []) {
      assertions =
        [
          {
            assertion = config.btrbk.enable;
            message = "${hostName} sends btrbk backups to ${lib.concatStringsSep ", " targets}, which needs btrbk.enable";
          }
        ]
        ++ map (target: {
          # ssh hosts get their host key pinned, which btrbk relies on since its known_hosts isn't persisted
          assertion = config.hosts ? ${target} && config.hosts.${target}.ssh && config.hosts.${target}.backup.receive != null;
          message = "backup target ${target} of ${hostName} must be an ssh host that sets backup.receive";
        })
        targets;
      services.btrbk.instances.btrbk.settings = {
        ssh_identity = config.sops.secrets.btrbk_ssh_key.path;
        subvolume."/home".target = targetsFor "home";
        subvolume."${config.persist.mountpoint}".target = targetsFor "persistent";
      };
      sops.secrets.btrbk_ssh_key = {
        format = "yaml";
        sopsFile = config.btrbk.sshKeySopsFile;
        key = "ssh_key";
        owner = config.users.users.btrbk.name;
      };
    })
    (lib.mkIf (receive != null) {
      # one key per sending host, confined to that host's directory
      services.btrbk.sshAccess = lib.mapAttrsToList (name: _: {
        key = builtins.readFile ../../keys/btrbk-${name}.pub;
        roles = [
          "target"
          "info"
          "receive"
          "delete"
        ];
        extraArgs = ["--restrict-path" "${receive}/${name}"];
      }) (lib.filterAttrs (_: host: lib.elem hostName host.backup.targets) config.hosts);
      # ssh_filter_btrbk only limits commands and the btrbk module can't add
      # `restrict` to the keys, so block forwarding for the btrbk user here
      services.openssh.extraConfig = lib.mkAfter ''
        Match User btrbk
          AllowAgentForwarding no
          AllowStreamLocalForwarding no
          AllowTcpForwarding no
          PermitTTY no
          PermitTunnel no
          X11Forwarding no
      '';
    })
  ]);
}
