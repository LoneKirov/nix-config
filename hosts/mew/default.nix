{config, ...}: {
  flake.nixosConfigurations.mew = config.flake.lib.nixosSystem {
    modules = [
      {
        imports = [
          ./btrfs.nix
          ./disk-config.nix
          ./framework-amd-ai-300-series
          ./hardware-configuration.nix
          ./kirov
          ./nix.nix
          ./services
        ];

        networking.hostName = "mew";
        boot.binfmt.emulatedSystems = ["aarch64-linux"];
        services.xserver.enable = true;
        system.stateVersion = "26.05";
        hardware.ledger.enable = true;
      }
    ];
  };
}
