_: {
  imports = [
    ../../profiles/raspberry-pi-3
    ./nix.nix
    ./services
    ./tailscale.nix
    ./upgrade.nix
    ./watchdog.nix
  ];

  system.stateVersion = "26.11";
  hardware.facter.reportPath = ./facter.json;
}
