{config, ...}: {
  services = {
    btrbk = {
      instances.btrbk.settings = {
        subvolume."${config.local.impermanence.persistentMountpoint}" = {
          target."/srv/backup/moltres/persistent" = {};
        };
        subvolume."/home" = {
          target."/srv/backup/moltres/home" = {};
        };
        subvolume."/srv/plex" = {
          snapshot_dir = "/srv/plex/.snapshots";
          target."/srv/backup/moltres/plex" = {};
        };
        subvolume."/srv/arr" = {
          snapshot_dir = "/srv/arr/.snapshots";
          target."/srv/backup/moltres/arr" = {};
        };
        subvolume."/srv/syncthing" = {
          snapshot_dir = "/srv/syncthing/.snapshots";
          target."/srv/backup/moltres/syncthing" = {};
        };
      };
      sshAccess = [
        {
          key = builtins.readFile ../../../keys/btrbk.pub;
          roles = [
            "target"
            "info"
            "receive"
            "delete"
          ];
        }
      ];
    };
    beesd.filesystems = {
      root = {
        spec = "/srv/root";
        hashTableSizeMB = 2048;
        extraOptions = ["--loadavg-target=2.0"];
      };
      storage = {
        spec = "/srv/storage";
        hashTableSizeMB = 6144;
        extraOptions = ["--loadavg-target=2.0"];
      };
    };
  };
}
