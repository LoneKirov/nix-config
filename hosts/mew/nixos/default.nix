{...}: {
  imports = [
    ./btrfs.nix
    ./disk-config.nix
    ./framework-amd-ai-300-series
    ./hardware-configuration.nix
    ./kirov
    ./services
  ];

  nixpkgs.config.allowUnfree = true;

  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  services.xserver.enable = true;

  system.stateVersion = "26.05";

  local.udev.ledger.enable = true;
}
