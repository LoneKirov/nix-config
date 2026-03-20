{
  config,
  lib,
  ...
}: {
  options.local.programs.nx.enable = lib.mkEnableOption "nx";

  config = lib.mkIf config.local.programs.nx.enable {
    programs.zsh.antidote.plugins = [
      "jscutlery/nx-completion"
    ];
  };
}
