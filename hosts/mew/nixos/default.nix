{...}: {
  imports = [
    ./hardware-configuration.nix # hardware scan configuration
    ./framework-amd-ai-300-series # framework specific configuration
    ./gui.nix # display manager, shell, and compositor configuration
    ./home-manager.nix # user and home-manager configuration
  ];

  networking.hostName = "mew";

  system.stateVersion = "25.11";
}
