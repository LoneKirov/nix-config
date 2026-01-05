{
  description = "A simple NixOS flake";

  inputs = {
    # standard nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # determinate nix
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    # convenient flake for linux systems
    systems.url = "github:nix-systems/default-linux";
    # predefined hardware configurations
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    # declarative disk formatting and fstab generation
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # impermanence alternative for persisting state
    preservation.url = "github:nix-community/preservation/main";
    # secureboot
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # declarative home directory
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # declarative neovim configuration
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
    };
    # latest quickshell for dms
    quickshell = {
      url = "git+https://git.outfoxxed.me/quickshell/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # declarative flatpak
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
  };

  outputs = {
    nixpkgs,
    determinate,
    systems,
    nixos-hardware,
    disko,
    preservation,
    lanzaboote,
    home-manager,
    nixvim,
    quickshell,
    nix-flatpak,
    ...
  }: let
    # helper to generate attributes for each system
    forAllSystems = f: nixpkgs.lib.genAttrs (import systems) f;
    # devShell factory to pass to forAllSystems
    devShell = system: let
      pkgs = nixpkgs.legacyPackages.${system};
      # custom neovim with nix lsps enabled
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
    # formatter factory to pass to forAllSystems
    formatter = system: nixpkgs.legacyPackages.${system}.alejandra;
  in {
    nixosConfigurations.mew = nixpkgs.lib.nixosSystem (let
      system = "x86_64-linux";
    in {
      inherit system;

      specialArgs = {
        inherit nixvim nix-flatpak; # pass through to load as a home-manager shared modules
        quickshell = quickshell.packages.${system}; # pass quickshell package through to dms
      };

      modules = [
        determinate.nixosModules.default
        nixos-hardware.nixosModules.framework-amd-ai-300-series
        disko.nixosModules.disko
        preservation.nixosModules.preservation
        lanzaboote.nixosModules.lanzaboote
        home-manager.nixosModules.home-manager
        ./nixos/configuration.nix
      ];
    });

    devShells = forAllSystems devShell;

    formatter = forAllSystems formatter;
  };
}
