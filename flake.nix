{
  description = "A basic flake with a shell";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default-linux";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    systems,
    nixpkgs,
    home-manager,
    ...
  }: let
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
    homeConfigurations = {
      "kirov@framework" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;

        modules = [
          ./home-manager/users/kirov.nix
          ({...}: {
            targets.genericLinux.enable = true;
          })
        ];
      };
    };

    devShells = forAllSystems devShell;

    formatter = forAllSystems formatter;
  };
}
