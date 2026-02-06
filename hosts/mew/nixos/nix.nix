{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.nix.enable {
    home-manager.users.kirov.home = {
      shellAliases = {
        nixos-rebuild = "nixos-rebuild --sudo --flake $XDG_CONFIG_HOME/nix-config";
        moltres-rebuild = "nixos-rebuild --sudo --flake $XDG_CONFIG_HOME/nix-config#moltres --target-host nixremote@moltres";
      };
    };
  };
}
