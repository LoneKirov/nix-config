{
  config,
  inputs,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.disko
  ];

  config = {
    disko.devices = {
      disk = {
        main = {
          type = "disk";
          device = "/dev/mmcblk0";
          content = {
            type = "gpt"; # hybrid mbr/gpt
            partitions = {
              # boot partition
              ESP = {
                priority = 1;
                name = "ESP";
                start = "1M";
                end = "512M";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = ["umask=0077"];
                };
              };
              root = {
                size = "100%";
                content = {
                  type = "btrfs";
                  extraArgs = ["-f"];
                  subvolumes = {
                    # subvolume for home directories
                    "/home" = {
                      mountOptions = ["compress=zstd"];
                      mountpoint = "/home";
                    };
                    "/home/.snapshots" = {};
                    # subvolume for nix store
                    "/nix" = {
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                      mountpoint = "/nix";
                    };
                    # subvolume for data kept by preservation
                    "/persistent" = {
                      mountOptions = [
                        "compress=zstd"
                      ];
                      mountpoint = config.local.impermanence.persistentMountpoint;
                    };
                    "/persistent/.snapshots" = {};
                    # subvolume for swapfile
                    "/swap" = {
                      mountpoint = "/.swap";
                      swap = {
                        swapfile.size = "2G";
                      };
                    };
                  };
                };
              };
            };
          };
        };
      };
      nodev = {
        # ephemeral root
        "/" = {
          fsType = "tmpfs";
          mountOptions = ["defaults" "size=25%" "mode=755"];
        };
      };
    };
  };
}
