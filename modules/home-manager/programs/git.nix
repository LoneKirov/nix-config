{
  config,
  lib,
  ...
}: {
  config = {
    programs = {
      git = {
        enable = lib.mkDefault true;
        settings = lib.mkMerge [
          {
            user = {
              name = lib.mkDefault "Adam Miller";
              email = lib.mkDefault "github@adammill.dev";
            };
            push.default = "simple";
            merge.conflictstyle = "diff3";
            pull.rebase = false;
          }
          (lib.mkIf config.programs.keybase.enable {
            protocol.keybase.allow = "always";
          })
        ];
      };
      zsh.antidote.plugins = lib.mkIf config.programs.git.enable [
        "ohmyzsh/ohmyzsh path:plugins/git"
      ];
    };
  };
}
