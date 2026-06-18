{
  config,
  lib,
  ...
}: {
  flake.nixosConfigurations.articuno = config.flake.lib.nixosSystem {
    modules = [
      {
        imports = [
          ./btrfs.nix
          ./disk-config.nix
          ./hardware-configuration.nix
          ./howdy.nix
          ./kirov
          ./lanzaboote.nix
          ./nvidia.nix
          ./services
        ];

        networking.hostName = "articuno";
        boot.binfmt.emulatedSystems = ["aarch64-linux"];
        services = {
          xserver.enable = true;
          openssh.enable = lib.mkForce true;
        };
        system.stateVersion = "26.05";
        hardware.ledger.enable = true;
      }
    ];
  };
}
