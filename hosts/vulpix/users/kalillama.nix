{config, ...}: let
  username = "kalillama";
in {
  config = {
    programs.zsh.enable = true;

    users.users.${username} = {
      home = "/Users/${username}";
    };

    home-manager = {
      users.${username} = {...}: {
        home = {
          homeDirectory = "/Users/${username}";
          stateVersion = config.home-manager.users.kirov.home.stateVersion;
        };

        programs.man.generateCaches = false;
      };
    };
  };
}
