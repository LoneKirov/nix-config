# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{...}: {
  imports = [
    ../../../modules/nixos # common nixos configuration
    ./hardware-configuration.nix # hardware scan configuration
    ./framework-amd-ai-300-series # framework specific configuration
    ./gui.nix # display manager, shell, and compositor configuration
    ./home-manager.nix # user and home-manager configuration
  ];

  networking.hostName = "mew";

  system.stateVersion = "25.11"; # Did you read the comment?
}
