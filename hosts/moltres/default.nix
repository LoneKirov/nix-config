{config, ...}:
config.flake.lib.nixosSystem {
  modules = [
    {networking.hostName = "moltres";}
    ./nixos
  ];
}
