{config, ...}: {
  services.btrbk = {
    instances.btrbk.settings = {
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
      subvolume."/srv/arr" = {
        snapshot_dir = "/srv/arr/.snapshots";
        target."/srv/backup/moltres/arr" = {};
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
