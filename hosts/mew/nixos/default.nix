{...}: {
  imports = [
    ./hardware-configuration.nix # hardware scan configuration
    ./framework-amd-ai-300-series # framework specific configuration
    # ./gui.nix # display manager, shell, and compositor configuration
  ];

  system.stateVersion = "25.11";
}
