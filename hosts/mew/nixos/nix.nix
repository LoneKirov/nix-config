{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.nix.enable {
    local.kirov.home-manager.home = {
      shellAliases = {
        nixos-rebuild = "nixos-rebuild --sudo --flake $XDG_CONFIG_HOME/nix-config";
        moltres-rebuild = ''NIX_SSHOPTS="-o IdentityAgent=$SSH_AUTH_SOCK" 'nixos-rebuild' --sudo --flake $XDG_CONFIG_HOME/nix-config#moltres --target-host nixremote@moltres'';
      };
    };
  };
}
