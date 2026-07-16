{config, ...}: {
  services = {
    btrbk = {
      instances.btrbk.settings = {
        subvolume."${config.preservation.persistentMountpoint}" = {
          target."ssh://moltres/srv/backup/slowpoke/persistent" = {};
        };
        subvolume."/home" = {
          target."ssh://moltres/srv/backup/slowpoke/home" = {};
        };
      };
    };
    beesd.filesystems.root = {
      spec = "/srv/root";
      hashTableSizeMB = 128;
      extraOptions = ["--loadavg-target=1.0"];
    };
  };
}
