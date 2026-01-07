{inputs, ...}: let
  inherit (inputs) nixpkgs;
in {
  flake.nixosConfigurations.mew = nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit inputs;
    };

    modules = with inputs; [
      determinate.nixosModules.default
      nixos-hardware.nixosModules.framework-amd-ai-300-series
      disko.nixosModules.disko
      preservation.nixosModules.preservation
      lanzaboote.nixosModules.lanzaboote
      home-manager.nixosModules.home-manager
      ./nixos/configuration.nix
    ];
  };
}
