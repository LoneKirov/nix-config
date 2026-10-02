{config, ...}: {
  services = {
    btrbk = {
      instances.btrbk.settings = {
        subvolume = {
          "${config.persist.mountpoint}" = {
            target."/srv/backup/moltres/persistent" = {};
          };
          "/home" = {
            target."/srv/backup/moltres/home" = {};
          };
          "/srv/arr" = {
            snapshot_dir = "/srv/arr/.snapshots";
            # in-progress downloads churn constantly and can't be split into their
            # own subvolume without breaking the *arr hardlinks
            snapshot_preserve = "24h 7d";
            target."/srv/backup/moltres/arr".target_preserve = "24h 14d 8w";
          };
          "/srv/syncthing" = {
            snapshot_dir = "/srv/syncthing/.snapshots";
            target."/srv/backup/moltres/syncthing" = {};
          };
        };
      };
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
