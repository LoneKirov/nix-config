{
  config,
  inputs,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.disko
  ];

  config = let
    storageKey = "${config.impermanence.persistentMountpoint}/etc/cryptsetup-keys.d/storage.key";
    backupKey = "${config.impermanence.persistentMountpoint}/etc/cryptsetup-keys.d/backup.key";
  in {
    disko.devices = {
      disk = {
        main = {
          type = "disk";
          device = "/dev/disk/by-id/nvme-eui.0025385a0144af49";
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
        storage1 = {
          type = "disk";
          device = "/dev/disk/by-id/wwn-0x5000c500eb83185c";
          content = {
            type = "gpt";
            partitions = {
              luks = {
                size = "100%";
                content = {
                  type = "luks";
                  name = "cryptstorage1";
                  initrdUnlock = false;
                  settings = {
                    allowDiscards = true;
                    keyFile = storageKey;
                  };
                };
              };
            };
          };
        };
        storage2 = {
          type = "disk";
          device = "/dev/disk/by-id/wwn-0x5000c500ebada367";
          content = {
            type = "gpt";
            partitions = {
              luks = {
                size = "100%";
                content = {
                  type = "luks";
                  name = "cryptstorage2";
                  initrdUnlock = false;
                  settings = {
                    allowDiscards = true;
                    keyFile = storageKey;
                  };
                };
              };
            };
          };
        };
        storage3 = {
          type = "disk";
          device = "/dev/disk/by-id/wwn-0x50014ee603f533a4";
          content = {
            type = "gpt";
            partitions = {
              luks = {
                size = "100%";
                content = {
                  type = "luks";
                  name = "cryptstorage3";
                  settings = {
                    allowDiscards = true;
                    keyFile = storageKey;
                  };
                };
              };
            };
          };
        };
        storage4 = {
          type = "disk";
          device = "/dev/disk/by-id/wwn-0x50014ee6aeb46398";
          content = {
            type = "gpt";
            partitions = {
              luks = {
                size = "100%";
                content = {
                  type = "luks";
                  name = "cryptstorage4";
                  settings = {
                    allowDiscards = true;
                    keyFile = storageKey;
                  };
                  content = {
                    type = "btrfs";
                    extraArgs = [
                      "-f"
                      "-d raid1"
                      "-m raid1c3"
                      "--label storage"
                      "/dev/mapper/cryptstorage1"
                      "/dev/mapper/cryptstorage2"
                      "/dev/mapper/cryptstorage3"
                    ];
                    subvolumes = {};
                  };
                };
              };
            };
          };
        };
        backup1 = {
          type = "disk";
          device = "/dev/disk/by-id/wwn-0x5000c500a5a27769";
          content = {
            type = "gpt";
            partitions = {
              luks = {
                size = "100%";
                content = {
                  type = "luks";
                  name = "cryptbackup1";
                  settings = {
                    allowDiscards = true;
                    keyFile = backupKey;
                  };
                };
              };
            };
          };
        };
        backup2 = {
          type = "disk";
          device = "/dev/disk/by-id/wwn-0x5000c500afd9dfed";
          content = {
            type = "gpt";
            partitions = {
              luks = {
                size = "100%";
                content = {
                  type = "luks";
                  name = "cryptbackup2";
                  settings = {
                    allowDiscards = true;
                    keyFile = backupKey;
                  };
                };
              };
            };
          };
        };
        backup3 = {
          type = "disk";
          device = "/dev/disk/by-id/wwn-0x50014ee6040ae354";
          content = {
            type = "gpt";
            partitions = {
              luks = {
                size = "100%";
                content = {
                  type = "luks";
                  name = "cryptbackup3";
                  initrdUnlock = false;
                  settings = {
                    allowDiscards = true;
                    keyFile = backupKey;
                  };
                };
              };
            };
          };
        };
        backup4 = {
          type = "disk";
          device = "/dev/disk/by-id/wwn-0x50014ee2b790a924";
          content = {
            type = "gpt";
            partitions = {
              luks = {
                size = "100%";
                content = {
                  type = "luks";
                  name = "cryptbackup4";
                  initrdUnlock = false;
                  settings = {
                    allowDiscards = true;
                    keyFile = backupKey;
                  };
                  content = {
                    type = "btrfs";
                    extraArgs = [
                      "-f"
                      "-d raid1"
                      "-m raid1c3"
                      "--label backup"
                      "/dev/mapper/cryptbackup1"
                      "/dev/mapper/cryptbackup2"
                      "/dev/mapper/cryptbackup3"
                    ];
                    subvolumes = {};
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
    environment.etc.crypttab.text = let
      disks = config.disko.devices.disk;
      mkCrypttabEntry = disk: let
        luks = disk.content.partitions.luks.content;
      in "${luks.name} ${disk.device}-part1 ${luks.settings.keyFile}";
    in ''
      ${mkCrypttabEntry disks.storage1}
      ${mkCrypttabEntry disks.storage2}
      ${mkCrypttabEntry disks.storage3}
      ${mkCrypttabEntry disks.storage4}
      ${mkCrypttabEntry disks.backup1}
      ${mkCrypttabEntry disks.backup2}
      ${mkCrypttabEntry disks.backup3}
      ${mkCrypttabEntry disks.backup4}
    '';
  };
}
