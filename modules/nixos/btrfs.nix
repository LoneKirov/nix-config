{
  config,
  lib,
  pkgs,
  ...
}: {
  nixpkgs.overlays = [
    # fix snbk
    (final: prev: {
      snapper = prev.snapper.overrideAttrs (old: {
        configureFlags =
          old.configureFlags
          ++ [
            "BTRFS_BIN=${lib.getExe' final.btrfs-progs "btrfs"}"
            "DIFF_BIN=${lib.getExe' final.diffutils "diff"}"
            "RM_BIN=${lib.getExe' final.coreutils "rm"}"
            "FINDMNT_BIN=${lib.getExe' final.util-linux "findmnt"}"
          ];
      });
    })
  ];
  services = {
    btrfs.autoScrub.enable = true;
    snapper.configs = {
      home = {
        SUBVOLUME = "/home";
        ALLOW_GROUPS = ["wheel"];
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;
      };
      persistent = {
        SUBVOLUME = config.impermanence.persistentMountpoint;
        ALLOW_GROUPS = ["wheel"];
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;
      };
    };
  };
  systemd = {
    services.snbk-backup = {
      description = "Backup of Snapper Snapshots";
      documentation = ["man:snbk(8)"];
      after = ["nss-user-lookup.target"];
      serviceConfig = {
        Type = "simple";
        WorkingDirectory = "/root";
        ExecStart = "${lib.getExe' pkgs.snapper "snbk"} --verbose --automatic transfer-and-delete";

        CapabilityBoundingSet = "CAP_DAC_OVERRIDE CAP_FOWNER CAP_CHOWN CAP_FSETID CAP_SETFCAP CAP_SYS_ADMIN CAP_SYS_MODULE CAP_IPC_LOCK CAP_SYS_NICE CAP_MKNOD";
        LockPersonality = true;
        NoNewPrivileges = false;
        ProtectHostname = true;
        RestrictRealtime = true;
      };
    };
    timers.snbk-backup = {
      description = "Backup of Snapper Snapshots";
      documentation = ["man:snbk(8)"];

      wantedBy = ["timers.target"];
      requires = ["local-fs.target"];

      timerConfig = {
        OnBootSec = "10m";
        OnUnitActiveSec = "1d";
      };
    };
  };
}
