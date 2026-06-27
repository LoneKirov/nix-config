{
  config,
  lib,
  pkgs,
  ...
}: {
  programs = {
    fish = {
      enable = lib.mkDefault true;
      interactiveShellInit = ''
        set fish_greeting # Disable greeting
      '';
    };
    bash.interactiveShellInit = lib.mkIf config.programs.fish.enable ''
      # "check if parent process is not fish" && "make nested shells work properly"
      if grep -qv fish /proc/$PPID/comm && [[ $SHLVL == [12] ]]; then
          # set $SHELL for better integration with programs like nix shell, tmux, etc.
          SHELL=${pkgs.fish}/bin/fish exec fish
      fi
    '';
  };
}
