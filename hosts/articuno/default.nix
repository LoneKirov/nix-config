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
  # Windows on the other drive keeps the RTC in local time; without this, each
  # OS boots with its clock off by the UTC offset after the other has run.
  time.hardwareClockInLocalTime = true;
  hardware.ledger.enable = true;
  user.hm = {
    programs.steam-flatpak.enable = true;
    services.rbw-agent.enable = true;
  };
}
