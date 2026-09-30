{
  imports = [
    ./btrfs.nix
    ./disk-config.nix
    ./kirov
    ./lanzaboote.nix
    ./services
  ];

  boot.binfmt.emulatedSystems = ["aarch64-linux"];
  networking.firewall.enable = false;
  system = {
    autoUpgrade.enable = true;
    stateVersion = "26.05";
  };
  users.users.nixremote.openssh.authorizedKeys.keys = [(builtins.readFile ../../keys/github.pub)];
  hardware.facter.reportPath = ./facter.json;
}
