{
  config,
  hostname,
  ...
}: {
  services.snapper.configs = {
    plex = {
      SUBVOLUME = "/srv/plex";
      ALLOW_GROUPS = ["wheel"];
      TIMELINE_CREATE = true;
      TIMELINE_CLEANUP = true;
    };
  };
  environment.etc."snapper/backup-configs/persistent.json".text = builtins.toJSON {
    config = "persistent";
    target-mode = "local";
    automatic = true;
    source-path = config.impermanence.persistentMountpoint;
    target-path = "/srv/backup/${hostname}/persistent";
  };
  environment.etc."snapper/backup-configs/home.json".text = builtins.toJSON {
    config = "home";
    target-mode = "local";
    automatic = true;
    source-path = "/home";
    target-path = "/srv/backup/${hostname}/home";
  };
  environment.etc."snapper/backup-configs/plex.json".text = builtins.toJSON {
    config = "plex";
    target-mode = "local";
    automatic = true;
    source-path = "/srv/plex";
    target-path = "/srv/backup/${hostname}/plex";
  };
}
