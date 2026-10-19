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
  options.btrbk.sshKeySopsFile = lib.mkOption {
    type = lib.types.path;
    description = "Sops file holding this host's btrbk ssh key under the `ssh_key` key; required when `host.backup.targets` is set.";
  };

  config = lib.mkIf hasBtrfs (lib.mkMerge [
    {
      services = {
        btrfs.autoScrub.enable = lib.mkDefault true;
        btrbk = {
          extraPackages = [pkgs.lz4];
          instances.btrbk = {
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
        };
      };
      systemd = {
        services.btrbk-btrbk = {
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
      };
      notify.healthchecks.btrbk-btrbk = "btrbk";
    }
    (lib.mkIf (targets != []) {
      assertions =
        map (target: {
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
