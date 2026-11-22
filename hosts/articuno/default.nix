{
  imports = [
    ./bluetooth.nix
    ./btrfs.nix
    ./disk-config.nix
    ./hardware-configuration.nix
    # ./howdy.nix
    ./lanzaboote.nix
    ./nvidia.nix
    ./services
  ];

  boot.binfmt.emulatedSystems = ["aarch64-linux"];
  system.stateVersion = "26.11";
  hardware.ledger.enable = true;
  user.hm = {
    programs.steam-flatpak.enable = true;
    services.rbw-agent.enable = true;
  };
}
