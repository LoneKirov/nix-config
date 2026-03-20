{
  config,
  inputs,
  lib,
  ...
}: {
  config = lib.mkIf config.nix.enable {
    programs.zsh.antidote.plugins = [
      "nix-community/nix-zsh-completions"
    ];

    home.shellAliases = let
      nixosConfigurations = inputs.self.outputs.nixosConfigurations;
      names = builtins.attrNames nixosConfigurations;
      aliases = map (host: {"${host}-rebuild" = ''NIX_SSHOPTS="-o IdentityAgent=$SSH_AUTH_SOCK" 'nixos-rebuild' --sudo --flake $XDG_CONFIG_HOME/nix-config#${host} --target-host nixremote@${host}'';}) names;
    in
      lib.mkMerge ([
          {
            nixos-rebuild = "'nixos-rebuild' --sudo --flake $XDG_CONFIG_HOME/nix-config";
          }
        ]
        ++ aliases);
  };
}
