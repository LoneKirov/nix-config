{
  imports = [
    ./btrfs.nix
    ./disk-config.nix
    ./framework-amd-ai-300-series
    ./kirov
    ./nix.nix
    ./services
  ];

  boot.binfmt.emulatedSystems = ["aarch64-linux"];
  system.stateVersion = "26.05";
  hardware = {
    facter.reportPath = ./facter.json;
    ledger.enable = true;
  };
}
