{config, ...}: {
  services = {
    btrbk.instances.btrbk.settings = {
      subvolume."${config.impermanence.persistentMountpoint}" = {
        target."ssh://moltres/srv/backup/articuno/persistent" = {};
      };
      subvolume."/home" = {
        target."ssh://moltres/srv/backup/articuno/home" = {};
      };
    };
    beesd.filesystems.root = {
      spec = "/srv/root";
      hashTableSizeMB = 3072;
      extraOptions = ["--loadavg-target=4.0"];
    };
  };
}
