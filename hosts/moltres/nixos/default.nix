{...}: {
  imports = [
    ./disk-config.nix
    ./hardware-configuration.nix # hardware scan configuration
    ./ssh.nix
  ];

  nixpkgs.config.allowUnfree = true;

  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  services.xserver.enable = false;

  system.stateVersion = "26.05";
}
