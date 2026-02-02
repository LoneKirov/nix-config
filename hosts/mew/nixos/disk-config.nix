{
  config,
  inputs,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.disko
  ];

  config.disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-eui.e8238fa6bf530001001b448b4df1708f";
        content = {
          type = "gpt";
          partitions = {
            # boot partition
            ESP = {
              priority = 1;
              name = "ESP";
              start = "1M";
              end = "1024M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["umask=0077"];
              };
            };
            # encrypted root btrfs
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "cryptroot";
                settings = {
                  allowDiscards = true;
                  crypttabExtraOpts = [
                    # update PCR 15 when volume is decrypted as a workaround for a malicious volume/init
                    # by only decrypting via tpm when PCR 15 is empty
                    "tpm2-device=auto"
                    "tpm2-measure-pcr=yes"
                  ];
                };
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
                      mountpoint = config.impermanence.persistentMountpoint;
                    };
                    "/persistent/.snapshots" = {};
                    # subvolume for swapfile
                    "/swap" = {
                      mountpoint = "/.swap";
                      swap = {
                        swapfile.size = "64G";
                      };
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
        mountOptions = ["defaults" "size=50%" "mode=755"];
      };
    };
  };
}
