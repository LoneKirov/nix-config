{
  config,
  lib,
  ...
}: {
  config.programs = {
    bat.enable = lib.mkDefault true;
    zsh.antidote.plugins = lib.mkIf config.programs.bat.enable [
      "fdellwing/zsh-bat"
    ];
  };
}
