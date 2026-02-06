{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.nix.enable {
    programs.zsh.zplug.plugins = [
      {name = "nix-community/nix-zsh-completions";}
    ];
  };
}
