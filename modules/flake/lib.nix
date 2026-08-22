{inputs, ...}: {
  flake.lib = {
    nixosSystem = {
      modules ? [],
      specialArgs ? {},
    }:
      inputs.nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;} // specialArgs;

        modules =
          [
            {nixpkgs.config.allowUnfree = true;}
            ../nixos
          ]
          ++ modules;
      };

    homeManagerConfiguration = {
      pkgs,
      modules ? [],
      extraSpecialArgs ? {},
    }:
      inputs.home-manager.lib.homeManagerConfiguration {
        extraSpecialArgs = {inherit inputs;} // extraSpecialArgs;

        inherit pkgs;

        modules =
          [
            ../home-manager
            ({
              config,
              lib,
              ...
            }: {
              nixpkgs.config.allowUnfree = true;
              home = {
                username = lib.mkDefault "kirov";
                homeDirectory = lib.mkDefault "/home/${config.home.username}";
              };
              programs.home-manager.enable = true;
            })
          ]
          ++ modules;
      };

    evalNixvim = {
      system,
      modules ? [],
    }:
      inputs.nixvim.lib.evalNixvim {
        inherit system;
        modules = [../nixvim] ++ modules;
      };
  };
}
