{config, ...}: {
  services = {
    btrfs.autoScrub.enable = true;
    btrbk.instances.btrbk = {
      onCalendar = "hourly";
      settings = {
        snapshot_create = "onchange";
        snapshot_preserve = "24h 14d 4w";
        snapshot_preserve_min = "1h";
        target_preserve = "24h 14d 12w 6m";
        target_preserve_min = "1h";
        stream_compress = "lz4";
        subvolume."/home" = {
          snapshot_dir = "/home/.snapshots";
        };
        subvolume."${config.impermanence.persistentMountpoint}" = {
          snapshot_dir = "${config.impermanence.persistentMountpoint}/.snapshots";
        };
      };
    };
  };
}
