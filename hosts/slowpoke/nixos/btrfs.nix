{config, ...}: {
  services.btrbk = {
    instances.btrbk.settings = {
      subvolume."${config.local.impermanence.persistentMountpoint}" = {
        target."ssh://moltres/srv/backup/slowpoke/persistent" = {};
      };
      subvolume."/home" = {
        target."ssh://moltres/srv/backup/slowpoke/home" = {};
      };
    };
  };
}
