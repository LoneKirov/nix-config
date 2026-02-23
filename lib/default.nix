{inputs, ...}: {
  mkNixosSystem = {
    hostname,
    username ? "kirov",
    modules ? [],
  }: let
    lib = inputs.nixpkgs.lib;
  in
    lib.nixosSystem {
      specialArgs = {
        inherit inputs;
      };

      modules =
        [
          # local.${username} convenience alias for host specific config
          (lib.mkAliasOptionModule ["local" username "nixos"] ["users" "users" username])
          (lib.mkAliasOptionModule ["local" username "home-manager"] ["home-manager" "users" username])
          # local.user alias for generic module config
          (lib.mkAliasOptionModule ["local" "user" "nixos"] ["users" "users" username])
          (lib.mkAliasOptionModule ["local" "user" "home-manager"] ["home-manager" "users" username])
          {networking.hostName = hostname;}
          ../modules/nixos
        ]
        ++ modules;
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
