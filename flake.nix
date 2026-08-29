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
      url = "github:nix-community/lanzaboote/v1.1.0";
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
    # declarative quadlets
    quadlet-nix.url = "github:SEIAROTg/quadlet-nix";
    # secrets
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # starship jujutsu support
    jj-starship = {
      url = "github:dmmulroy/jj-starship";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # jujutsu github pr support
    jj-gh = {
      url = "github:mrjones2014/jj-gh";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # wsl support
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
  };

  outputs = inputs @ {
    flake-parts,
    systems,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} (_: {
      systems = import systems;
      imports = [
        ./modules/flake
        ./hosts
      ];
    });
}
