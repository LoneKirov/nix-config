{...}: {
  imports = [
    ./btrfs.nix
    ./disk-config.nix
    ./hardware-configuration.nix # hardware scan configuration
    ./kirov
    ./services
  ];

  nixpkgs.config.allowUnfree = true;

  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  services.xserver.enable = false;

  networking.firewall.enable = false;

  system = {
    autoUpgrade.enable = true;

    stateVersion = "26.05";
  };
}
