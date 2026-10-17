_: {
  imports = [
    ./disk-config.nix
    ./nix.nix
    ./raspberry-pi-3
    ./services
    ./tailscale.nix
    ./upgrade.nix
  ];

  system.stateVersion = "26.05";
  hardware.facter.reportPath = ./facter.json;
}
