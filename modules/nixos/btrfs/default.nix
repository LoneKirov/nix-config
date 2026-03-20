{
  config,
  pkgs,
  ...
}: {
  services = {
    btrfs.autoScrub.enable = true;
    btrbk = {
      extraPackages = [pkgs.lz4];
      instances.btrbk = {
        onCalendar = "hourly";
        settings = {
          ssh_identity = config.sops.secrets.btrbk_ssh_key.path;
          ssh_user = "btrbk";
          snapshot_create = "onchange";
          snapshot_preserve = "24h 14d 4w";
          snapshot_preserve_min = "1h";
          target_preserve = "24h 14d 12w 6m";
          target_preserve_min = "1h";
          stream_compress = "lz4";
          subvolume."/home" = {
            snapshot_dir = "/home/.snapshots";
          };
          subvolume."${config.local.impermanence.persistentMountpoint}" = {
            snapshot_dir = "${config.local.impermanence.persistentMountpoint}/.snapshots";
          };
        };
      };
    };
  };
  sops.secrets.btrbk_ssh_key = {
    format = "yaml";
    sopsFile = ./btrbk.sops.yaml;
    key = "ssh_key";
    owner = config.users.users.btrbk.name;
  };
}
