{config, ...}: {
  imports = [
    ./btrfs.nix
    ./disk-config.nix
    ./framework-amd-ai-300-series
    ./services
  ];

  boot.binfmt.emulatedSystems = ["aarch64-linux"];
  # push and pull access to the kanto cache, for attic-client in home-manager
  sops.secrets.attic-token = {
    format = "yaml";
    sopsFile = ./attic-token.sops.yaml;
    key = "token";
    owner = config.user.username;
  };
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
