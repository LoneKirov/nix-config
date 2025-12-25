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
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
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
    nixvim,
    ...
  }: let
    forAllSystems = f: nixpkgs.lib.genAttrs (import systems) f;
    devShell = system: let
      pkgs = nixpkgs.legacyPackages.${system};
      nvim = nixvim.legacyPackages.${system}.makeNixvimWithModule {
        inherit pkgs;
        module = {...}: {
          imports = [
            ./nixvim
            ./nixvim/lsp/nix.nix
          ];
        };
      };
    in {
      default = with pkgs;
        mkShell {
          buildInputs = [nvim];
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
        {
          home-manager = {
            sharedModules = [nixvim.homeModules.nixvim];
            useUserPackages = true;
            useGlobalPkgs = true;
          };
        }
        ./nixos/configuration.nix
      ];
    };

    devShells = forAllSystems devShell;

    formatter = forAllSystems formatter;
  };
}
