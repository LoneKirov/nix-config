{...}: {
  imports = [
    ./disk-config.nix
    ./hardware-configuration.nix # hardware scan configuration
    ./services
    ./snapper.nix
  ];

  nixpkgs.config.allowUnfree = true;

  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  services.xserver.enable = false;

  networking.firewall.enable = false;

  system.stateVersion = "26.05";
}
