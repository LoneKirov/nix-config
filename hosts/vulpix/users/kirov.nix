{inputs, ...}: let
  username = "kirov";
in {
  imports = [
    inputs.home-manager.darwinModules.home-manager
  ];

  config = {
    programs.fish.enable = true;

    users.users.${username} = {
      home = "/Users/${username}";

      openssh.authorizedKeys.keys = [(builtins.readFile ../../../keys/kirov.pub)];
    };

    home-manager = {
      extraSpecialArgs = {
        inherit inputs;
      };
      useUserPackages = true;
      useGlobalPkgs = true;

      users.${username} = {...}: {
        imports = [../../../modules/home-manager];

        home = {
          homeDirectory = "/Users/${username}";
          stateVersion = "26.11";
        };

        programs.man.generateCaches = false;
      };
    };
  };
}
