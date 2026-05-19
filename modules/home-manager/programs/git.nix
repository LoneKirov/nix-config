{
  config,
  lib,
  ...
}: {
  config = {
    programs = {
      git = {
        enable = lib.mkDefault true;
        settings = {
          user = {
            name = "Adam Miller";
            email = "github@adammill.dev";
          };
          protocol.keybase.allow = "always";
          push.default = "simple";
          merge.conflictstyle = "diff3";
          pull.rebase = false;
        };
      };
      zsh.antidote.plugins = lib.mkIf config.programs.git.enable [
        "ohmyzsh/ohmyzsh path:plugins/git"
      ];
    };
  };
}
