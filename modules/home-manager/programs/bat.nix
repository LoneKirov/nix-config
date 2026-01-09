{
  config,
  lib,
  ...
}: {
  config = {
    programs.bat.enable = lib.mkDefault true;
    programs.zsh.zplug.plugins = lib.mkIf config.programs.bat.enable [
      {name = "fdellwing/zsh-bat";}
    ];
  };
}
