{
  config,
  lib,
  pkgs,
  ...
}: {
  options.programs.nx.enable = lib.mkEnableOption "nx";

  config = lib.mkIf config.programs.nx.enable {
    programs = {
      zsh.antidote.plugins = [
        "jscutlery/nx-completion"
      ];
      fish.plugins = [
        {
          name = "nx";
          src = pkgs.fetchFromGitHub {
            owner = "jukben";
            repo = "fish-nx";
            rev = "7818a8b9fee2adcd20a1bd68cdd7af2f6379c46c";
            sha256 = "ypoMIC4cFA7ZvkqAoyykd11NvGkc/x8g0SjngHl+uDE=";
          };
        }
      ];
    };
  };
}
