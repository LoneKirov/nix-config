{
  imports = [
    ./btrfs.nix
    ./disk-config.nix
    ./framework-amd-ai-300-series
    ./services
  ];

  boot.binfmt.emulatedSystems = ["aarch64-linux"];
  system.stateVersion = "26.05";
  hardware = {
    facter.reportPath = ./facter.json;
    ledger.enable = true;
  };
  user.hm = {
    programs.steam-flatpak.enable = true;
    services.rbw-agent.enable = true;
  };
}
