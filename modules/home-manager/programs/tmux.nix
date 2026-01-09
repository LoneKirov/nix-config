{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkMerge [
    {programs.tmux.enable = lib.mkDefault true;}
    (lib.mkIf config.programs.tmux.enable {
      programs.tmux = {
        prefix = "C-a";
        keyMode = "vi";
        sensibleOnTop = true;
        terminal = "tmux-256color";
        focusEvents = true;
        escapeTime = 10;
        extraConfig = ''
          set -a terminal-features xterm-256color:RGB
        '';
        plugins = with pkgs.tmuxPlugins; [
          {
            plugin = resurrect;
            extraConfig = ''
              set -g @resurrect-dir '${config.xdg.stateHome}/tmux/resurrect'
              set -g @resurrect-processes 'bmon "dmesg -w" atop btop'
            '';
          }
          {
            plugin = continuum;
            extraConfig = "set -g @continuum-restore 'on'";
          }
        ];
      };
      programs.zsh.zplug.plugins = [
        {
          name = "plugins/tmux";
          tags = ["from:oh-my-zsh"];
        }
      ];
    })
  ];
}
