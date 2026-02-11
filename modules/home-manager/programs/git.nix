{
  config,
  lib,
  ...
}: {
  config = lib.mkMerge [
    {programs.git.enable = lib.mkDefault true;}
    (lib.mkIf config.programs.git.enable {
      programs = {
        git = {
          settings = {
            user.name = "Adam Miller";
            user.email = "github@adammill.dev";
            protocol.keybase.allow = "always";
            push.default = "simple";
            merge.conflictstyle = "diff3";
            pull.rebase = false;
          };
        };
        zsh.antidote.plugins = [
          "ohmyzsh/ohmyzsh path:plugins/git"
        ];
      };
    })
  ];
}
