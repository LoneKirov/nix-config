{inputs, ...}: {
  flake.lib = {
    nixosSystem = {
      modules ? [],
      specialArgs ? {},
    }: let
      lib = inputs.nixpkgs.lib;
    in
      lib.nixosSystem {
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
      username ? "kirov",
      modules ? [],
      extraSpecialArgs ? {},
    }:
      inputs.home-manager.lib.homeManagerConfiguration {
        extraSpecialArgs = {inherit inputs;} // extraSpecialArgs;

        inherit pkgs;

        modules =
          [
            ../home-manager
            ({...}: {
              nixpkgs.config.allowUnfree = true;
              home = {
                inherit username;
                homeDirectory = "/home/${username}";
              };
              programs.home-manager.enable = true;
            })
          ]
          ++ modules;
      };
  };
}
