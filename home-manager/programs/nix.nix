{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.nix.enable {
    home = {
      packages = with pkgs; [
        cachix
      ];
      shellAliases = {
        nixos-rebuild = "nixos-rebuild --sudo --flake $XDG_CONFIG_HOME/nix-config";
      };
    };

    programs.zsh.zplug.plugins = [
      {name = "nix-community/nix-zsh-completions";}
    ];
  };
}
