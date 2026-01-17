{
  description = "Kirov's Nix flake";

  inputs = {
    # modular flakes
    flake-parts.url = "github:hercules-ci/flake-parts";
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
      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
        flake-parts.follows = "flake-parts";
      };
    };
    # latest quickshell for dms
    quickshell = {
      url = "git+https://git.outfoxxed.me/quickshell/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dms-plugin-registry = {
      url = "github:AvengeMedia/dms-plugin-registry";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # declarative flatpak
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    # nix-index with a regularly updated database
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    flake-parts,
    systems,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} ({...}: {
      systems = import systems;
      imports = [
        ./modules/flake
        ./hosts
      ];
      flake = {};
    });
}
