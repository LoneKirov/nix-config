{config, ...}:
config.flake.lib.nixosSystem {
  modules = [
    {networking.hostName = "slowpoke";}
    ./nixos
  ];
}
