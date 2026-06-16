{config, ...}:
config.flake.lib.nixosSystem {
  modules = [
    {networking.hostName = "articuno";}
    ./nixos
  ];
}
