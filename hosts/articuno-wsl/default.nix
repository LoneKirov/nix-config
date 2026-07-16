{config, ...}: {
  flake.nixosConfigurations.articuno-wsl = config.flake.lib.nixosSystem {
    modules = [
      {
        imports = [
          ./kirov
          ./wsl.nix
        ];

        networking.hostName = "articuno-wsl";

        system.stateVersion = "26.05";
      }
    ];
  };
}
