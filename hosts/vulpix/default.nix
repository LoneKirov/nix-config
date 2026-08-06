{inputs, ...}: {
  flake.darwinConfigurations.vulpix = inputs.nix-darwin.lib.darwinSystem {
    specialArgs = {inherit inputs;};

    modules = [
      {
        imports = [
          ./nix.nix
          ./packages.nix
          ./ssh.nix
          ./users
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
