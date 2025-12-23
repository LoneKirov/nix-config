{
  description = "A simple NixOS flake";

  inputs = {
    systems.url = "github:nix-systems/default-linux";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    preservation.url = "github:nix-community/preservation/main";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    systems,
    nixpkgs,
    nixos-hardware,
    disko,
    preservation,
    lanzaboote,
    home-manager,
    ...
  } @ inputs: let
    forAllSystems = f: nixpkgs.lib.genAttrs (import systems) f;
    devShell = system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      default = with pkgs;
        mkShell {
          packages = [
            alejandra
            nil
            nixd
          ];
        };
    };
    formatter = system: nixpkgs.legacyPackages.${system}.alejandra;
  in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        nixos-hardware.nixosModules.framework-amd-ai-300-series
        disko.nixosModules.disko
        preservation.nixosModules.preservation
        lanzaboote.nixosModules.lanzaboote
        home-manager.nixosModules.home-manager
        ./nixos/configuration.nix
      ];
    };

    devShells = forAllSystems devShell;

    formatter = forAllSystems formatter;
  };
}
