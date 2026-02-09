{config, ...}: {
  services.btrbk = {
    instances.moltres.settings = {
      subvolume."${config.impermanence.persistentMountpoint}" = {
        target."/srv/backup/moltres/persistent" = {};
      };
      subvolume."/home" = {
        target."/srv/backup/moltres/home" = {};
      };
      subvolume."/srv/plex" = {
        snapshot_dir = "/srv/plex/.snapshots";
        target."/srv/backup/moltres/plex" = {};
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
}
