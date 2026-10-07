{
  config,
  lib,
  pkgs,
  ...
}: {
  config = {
    programs = {
      fzf = {
        enable = lib.mkDefault true;
        historyWidget.command = "";
      };
      fish = lib.mkIf config.programs.fzf.enable {
        plugins = [
          {
            name = "fzf";
            inherit (pkgs.fishPlugins.fzf-fish) src;
          }
        ];
        # give ctrl-v back to paste, and leave ctrl-r to atuin; this erases the
        # plugin's default bindings, so it has to run before atuin binds ctrl-r
        interactiveShellInit = lib.mkBefore ''
          fzf_configure_bindings --variables=ctrl-alt-v --history=
        '';
      };
    };
  };
}
