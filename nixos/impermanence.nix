{...}: {
  # need /persistent available in initrd so preservation has access to it
  fileSystems."/persistent".neededForBoot = true;
  # Setup preservation to maintain state between wipes of /
  preservation = {
    enable = true;
    preserveAt."/persistent" = {
      directories = [
        "/etc/nixos" # persist until user/github repo is setup
        {
          directory = "/etc/secureboot"; # persist secureboot config
          inInitrd = true; # making it available early just in case
        }
        "/etc/NetworkManager/system-connections" # NM connections
        {
          directory = "/var/lib/nixos"; # stores nixos state for generating stable uids and gids
          inInitrd = true; # make it available for nix in initrd
        }
        "/var/lib/fwupd" # firmware update store
        "/var/lib/sbctl" # persist secureboot keys managed by sbctl
        {
          directory = "/var/lib/systemd/coredump"; # coredump store
          inInitrd = true; # make it available for systemd in initrd
        }
        {
          directory = "/var/lib/systemd/rfkill"; # RF kill switch state store
          inInitrd = true; # make it available for systemd in initrd
        }
        {
          directory = "/var/lib/systemd/timers"; # timers state store
          inInitrd = true; # make it available for systemd in initrd
        }
        "/var/lib/upower" # power statistics and history
        {
          directory = "/var/log"; # system logs
          inInitrd = true; # make it available for journald in initrd
        }
      ];
      files = [
        {
          # machine id. needs to be available early in boot
          file = "/etc/machine-id";
          how = "symlink";
          inInitrd = true;
          configureParent = true;
          createLinkTarget = true;
        }
        {
          # random seed. needs to be available early in boot
          file = "/var/lib/systemd/random-seed";
          how = "symlink";
          inInitrd = true;
        }
      ];
    };
  };
  boot.initrd.systemd.tmpfiles.settings.preservation."/sysroot/persistent/etc/machine-id".f = {
    argument = "uninitialized";
  };
}
