{inputs, ...}: {
  flake.darwinConfigurations.vulpix = inputs.nix-darwin.lib.darwinSystem {
    specialArgs = {inherit inputs;};

    modules = [
      {
        imports = [
          ./kirov
          ./nix
          ./ssh.nix
        ];

        nixpkgs = {
          hostPlatform = "aarch64-darwin";
          config.allowUnfree = true;
        };

        networking.hostName = "vulpix";

        system.stateVersion = 6;
      }
    ];
  };
}
