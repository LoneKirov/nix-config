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
      # pinned to a specific revision until there is a better way to remove
      # 350-action-efi-application.pcrlock for some hosts
      url = "github:nix-community/lanzaboote?rev=001e560fffc8f0235e9db20ebeb4ccde0ade1caf";
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
        nixpkgs.follows = "nixpkgs"; # https://github.com/nix-community/nixvim/issues/4463
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
    });
}
