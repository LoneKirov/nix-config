{...}: {
  imports = [
    ./disk-config.nix
    ./hardware-configuration.nix # hardware scan configuration
    ./framework-amd-ai-300-series # framework specific configuration
    ./btrfs.nix
    ./ledger.nix
    ./nix.nix
    ./ssh.nix
    ./steam.nix
    ./vicinae.nix
  ];

  nixpkgs.config.allowUnfree = true;

  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  services.xserver.enable = true;

  system.stateVersion = "26.05";
}
