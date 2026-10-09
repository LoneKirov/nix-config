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
                  mountpoint = "/srv/root";
                  subvolumes = {
                    "/home" = {
                      mountOptions = ["compress=zstd"];
                      mountpoint = "/home";
                    };
                    "/home/.snapshots" = {};
                    "/nix" = {
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                      mountpoint = "/nix";
                    };
                    "/persistent" = {
                      mountOptions = [
                        "compress=zstd"
                      ];
                      mountpoint = config.persist.mountpoint;
                    };
                    "/persistent/.snapshots" = {};
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
        "/" = {
          fsType = "tmpfs";
          mountOptions = ["defaults" "size=25%" "mode=755"];
        };
      };
    };
  };
}
