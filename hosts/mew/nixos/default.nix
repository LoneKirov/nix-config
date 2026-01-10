{...}: {
  imports = [
    ./hardware-configuration.nix # hardware scan configuration
    ./framework-amd-ai-300-series # framework specific configuration
    ./steam.nix
  ];

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "25.11";
}
