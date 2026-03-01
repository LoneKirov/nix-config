{...}: {
  imports = [
    ./btrfs.nix
    ./disk-config.nix
    ./hardware-configuration.nix
    ./kirov
    ./framework-amd-ai-300-series
    ./ledger.nix
    ./nix.nix
    ./ssh.nix
  ];

  nixpkgs.config.allowUnfree = true;

  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  services.xserver.enable = true;

  system.stateVersion = "26.05";
}
