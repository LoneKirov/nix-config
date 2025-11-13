{
  config,
  lib,
  ...
}: {
  config = {
    programs.git = lib.mkMerge [
      {enable = lib.mkDefault true;}
      (lib.mkIf config.programs.git.enable {
        settings = {
          user.name = "Adam Miller";
          user.email = "github@adammill.dev";
          protocol.keybase.allow = "always";
          push.default = "simple";
          merge.conflictstyle = "diff3";
          pull.rebase = false;
        };
      })
    ];
    programs.zsh.zplug.plugins = lib.mkIf config.programs.git.enable [
      {
        name = "plugins/git";
        tags = ["from:oh-my-zsh"];
      }
    ];
  };
}
