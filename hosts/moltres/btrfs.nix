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
            target."/srv/backup/moltres/arr" = {};
          };
          # nested inside /srv/arr, so /srv/arr's snapshots stop at it. Downloads
          # and media share it to keep the *arr hardlinks; downloads churn
          # constantly and the arr apps can fetch media again, so it keeps less
          # history than their state
          "/srv/arr/data" = {
            snapshot_dir = "/srv/arr/.snapshots";
            snapshot_preserve = "24h 7d";
            target."/srv/backup/moltres/arr-data".target_preserve = "14d";
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
        hashTableSizeMB = 256;
        extraOptions = ["--loadavg-target=4.0"];
      };
      storage = {
        spec = "/srv/storage";
        hashTableSizeMB = 1024;
        extraOptions = ["--loadavg-target=4.0"];
      };
      backup = {
        spec = "/srv/backup";
        hashTableSizeMB = 3584;
        extraOptions = ["--loadavg-target=4.0"];
      };
    };
  };
}
