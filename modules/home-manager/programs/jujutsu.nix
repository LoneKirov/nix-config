{
  config,
  lib,
  pkgs,
  ...
}: {
  config = let
    inherit (config.programs.jujutsu) enable;
  in {
    programs = {
      jujutsu = {
        enable = lib.mkDefault config.programs.git.enable;
        settings = {
          user = config.programs.git.settings.user;
        };
      };
      jjui.enable = enable;
      zsh.antidote.plugins = lib.mkIf enable [
        "ohmyzsh/ohmyzsh path:plugins/jj"
      ];
    };
  };
}
