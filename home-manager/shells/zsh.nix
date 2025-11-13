{
  config,
  pkgs,
  ...
}: {
  config = {
    # zplug needs perl
    home.packages = with pkgs; [perl];
    programs.zsh = {
      enable = true;
      dotDir = "${config.xdg.configHome}/zsh";
      history.path = "${config.xdg.stateHome}/zsh/zsh_history";
      zplug = {
        enable = true;
        zplugHome = "${config.xdg.stateHome}/zplug";
        plugins = [
          {name = "zsh-users/zsh-autosuggestions";}
          {name = "zsh-users/zsh-syntax-highlighting";}
          {
            name = "plugins/sudo";
            tags = ["from:oh-my-zsh"];
          }
          {
            name = "plugins/colored-man-pages";
            tags = ["from:oh-my-zsh"];
          }
          {name = "marlonrichert/zsh-autocomplete";}
        ];
      };
      enableCompletion = false;
      shellAliases = {
        wget = "wget --no-hsts";
      };
    };
  };
}
