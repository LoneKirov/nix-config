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
      # don't want to run at the same time as moltres
      dates = "*-*-* 05:00:00";
    };
    stateVersion = "26.05";
  };
  hardware.facter.reportPath = ./facter.json;
}
