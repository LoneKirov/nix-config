{pkgs, ...}: {
  imports = [
    ../shells
    ../programs
    ../services
  ];

  config = {
    xdg.enable = true;

    home = {
      stateVersion = "25.05";
      username = "kirov";
      homeDirectory = "/home/kirov";
      sessionPath = ["$HOME/.local/bin"];
      packages = with pkgs; [
        nerd-fonts.fira-code
      ];
      file = {};
      sessionVariables = {};
    };

    programs = {
      home-manager.enable = true;

      zsh.zplug.plugins = [
        {
          name = "plugins/ssh-agent";
          tags = ["from:oh-my-zsh"];
        }
        {
          name = "plugins/systemd";
          tags = ["from:oh-my-zsh"];
        }
      ];
    };
  };
}
