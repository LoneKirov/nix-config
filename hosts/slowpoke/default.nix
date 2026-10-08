_: {
  imports = [
    ./btrfs.nix
    ./disk-config.nix
    ./nix.nix
    ./raspberry-pi-3
    ./services
    ./tailscale.nix
  ];

  system = {
    autoUpgrade = {
      enable = true;
      # after moltres's 03:00 upgrade, since this pulls from the cache moltres serves
      dates = "*-*-* 05:00:00";
    };
    stateVersion = "26.05";
  };
  hardware.facter.reportPath = ./facter.json;
}
