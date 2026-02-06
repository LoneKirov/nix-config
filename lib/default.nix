{inputs, ...}: {
  mkNixosSystem = {
    hostname,
    authorizedKeys ? [],
    username ? "kirov",
    modules ? [],
  }:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs username hostname authorizedKeys;
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
}
