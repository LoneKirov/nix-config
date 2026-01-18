{inputs, ...}: {
  mkNixosSystem = {
    hostname,
    username ? "kirov",
    modules ? [],
  }:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs username hostname;
      };

      modules = [../modules/nixos] ++ modules;
    };

  mkHomeManagerConfiguration = {
    pkgs,
    username ? "kirov",
    modules ? [],
  }:
    inputs.home-manager.lib.homeManagerConfiguration {
      extraSpecialArgs = {
        inherit inputs;
      };

      inherit pkgs;

      modules =
        [
          ../modules/home-manager
          ({...}: {
            home = {
              inherit username;
              homeDirectory = "/home/${username}";
            };
            programs.home-manager.enable = true;
          })
        ]
        ++ modules;
    };
}
