{...}: {
  services.btrfs.autoScrub.enable = true;
  services.snapper.configs = {
    home = {
      SUBVOLUME = "/home";
      ALLOW_GROUPS = ["wheel"];
      TIMELINE_CREATE = true;
      TIMELINE_CLEANUP = true;
    };
    persistent = {
      SUBVOLUME = "/persistent";
      ALLOW_GROUPS = ["wheel"];
      TIMELINE_CREATE = true;
      TIMELINE_CLEANUP = true;
    };
  };
}
