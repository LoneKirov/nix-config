{config, ...}:
config.flake.lib.nixosSystem {
  modules = [
    {networking.hostName = "mew";}
    ./nixos
  ];
}
