{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.nix.enable {
    programs.zsh.antidote.plugins = [
      "nix-community/nix-zsh-completions"
    ];
  };
}
