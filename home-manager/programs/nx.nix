{
  config,
  lib,
  ...
}: {
  options.programs.nx.enable = lib.mkEnableOption "nx";

  config = lib.mkIf config.programs.nx.enable {
    programs.zsh.zplug.plugins = [
      {name = "jscutlery/nx-completion";}
    ];
  };
}
