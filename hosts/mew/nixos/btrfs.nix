{config, ...}: {
  services.btrbk.instances.btrbk.settings = {
    subvolume."${config.impermanence.persistentMountpoint}" = {
      # TODO: only use target when on home network
      # target."ssh://moltres/srv/backup/mew/persistent" = {};
    };
    subvolume."/home" = {
      # target."ssh://moltres/srv/backup/mew/home" = {};
    };
  };
}
