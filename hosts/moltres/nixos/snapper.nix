{...}: {
  services.snapper.configs = {
    plex = {
      SUBVOLUME = "/srv/plex";
      ALLOW_GROUPS = ["wheel"];
      TIMELINE_CREATE = true;
      TIMELINE_CLEANUP = true;
    };
  };
}
