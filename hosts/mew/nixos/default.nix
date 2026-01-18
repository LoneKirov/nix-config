{...}: {
  imports = [
    ./hardware-configuration.nix # hardware scan configuration
    ./framework-amd-ai-300-series # framework specific configuration
    ./ssh.nix
    ./steam.nix
  ];

  nixpkgs.config.allowUnfree = true;

  services.xserver.enable = true;

  system.stateVersion = "25.11";
}
