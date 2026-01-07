{config, ...}: {
  services.btrfs.autoScrub.enable = true;
  services.snapper.configs = {
    home = {
      SUBVOLUME = "/home";
      ALLOW_GROUPS = ["wheel"];
      TIMELINE_CREATE = true;
      TIMELINE_CLEANUP = true;
    };
    persistent = {
      SUBVOLUME = config.impermanence.persistentMountpoint;
      ALLOW_GROUPS = ["wheel"];
      TIMELINE_CREATE = true;
      TIMELINE_CLEANUP = true;
    };
  };
}
