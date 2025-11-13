{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.nix.enable {
    home.packages = with pkgs; [
      cachix
    ];

    programs.zsh.zplug.plugins = [
      {name = "nix-community/nix-zsh-completions";}
    ];
  };
}
