{
  config,
  lib,
  pkgs,
  ...
}: let
  gui = config.host.gui;
in {
  config = {
    programs = {
      tmux = {
        enable = lib.mkDefault (!gui);
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
              set -g @resurrect-processes 'bmon "dmesg -w" atop btm'
            '';
          }
          {
            plugin = continuum;
            extraConfig = "set -g @continuum-restore 'on'";
          }
        ];
      };
      zsh.antidote.plugins = lib.optionals config.programs.tmux.enable [
        "ohmyzsh/ohmyzsh path:plugins/tmux"
      ];
    };
  };
}
