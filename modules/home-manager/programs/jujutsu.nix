{
  config,
  lib,
  ...
}: {
  config = {
    programs = {
      jujutsu = {
        enable = lib.mkDefault config.programs.git.enable;
        settings = {
          user = config.programs.git.settings.user;
        };
      };
      jjui.enable = config.programs.jujutsu.enable;
      zsh.antidote.plugins = lib.mkIf config.programs.jujutsu.enable [
        "ohmyzsh/ohmyzsh path:plugins/jj"
      ];
    };
  };
}
