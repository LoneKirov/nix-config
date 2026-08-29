{config, ...}: {
  services = {
    btrbk = {
      instances.btrbk.settings = {
        subvolume = {
          "${config.preservation.persistentMountpoint}" = {
            target."/srv/backup/moltres/persistent" = {};
          };
          "/home" = {
            target."/srv/backup/moltres/home" = {};
          };
          "/srv/plex" = {
            snapshot_dir = "/srv/plex/.snapshots";
            target."/srv/backup/moltres/plex" = {};
          };
          "/srv/arr" = {
            snapshot_dir = "/srv/arr/.snapshots";
            target."/srv/backup/moltres/arr" = {};
          };
          "/srv/syncthing" = {
            snapshot_dir = "/srv/syncthing/.snapshots";
            target."/srv/backup/moltres/syncthing" = {};
          };
        };
      };
      sshAccess = [
        {
          key = builtins.readFile ../../keys/btrbk.pub;
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
        hashTableSizeMB = 1024;
        extraOptions = ["--loadavg-target=4.0"];
      };
      storage = {
        spec = "/srv/storage";
        hashTableSizeMB = 7168;
        extraOptions = ["--loadavg-target=4.0"];
      };
      backup = {
        spec = "/srv/backup";
        hashTableSizeMB = 7168;
        extraOptions = ["--loadavg-target=4.0"];
      };
    };
  };
}
