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
  # swap in compressed RAM rather than on the SD card
  zramSwap.enable = true;
  # its only disk is the SD card, which has no SMART
  services.smartd.enable = false;
}
