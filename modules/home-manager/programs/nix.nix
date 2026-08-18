{
  config,
  inputs,
  lib,
  osConfig,
  ...
}: {
  options.nix.buildAliases.enable = lib.mkEnableOption "buildAliases";

  config = lib.mkIf config.nix.enable {
    programs.zsh.antidote.plugins = [
      "nix-community/nix-zsh-completions"
    ];

    programs.fish.shellAliases = let
      nixosConfigurations = inputs.self.outputs.nixosConfigurations;
      hosts = builtins.attrNames nixosConfigurations;
      includeBuildAlias = host: let
        cfg = nixosConfigurations.${host}.config;
        xserver = cfg.services.xserver.enable or false;
        wsl = cfg.wsl.enable or false;
      in
        ! (xserver || wsl);
      buildAliases = builtins.filter includeBuildAlias hosts;
      flake = osConfig.programs.nh.flake or "";
      mkBuildAlias = host: {
        "${host}-rebuild" = ''NIX_SSHOPTS="-o IdentityAgent=$SSH_AUTH_SOCK" nixos-rebuild --sudo --flake ${flake}#${host} --target-host nixremote@${host}'';
      };
      aliases =
        if config.nix.buildAliases.enable
        then map mkBuildAlias buildAliases
        else [];
    in
      lib.mkMerge ([
          {
            nixos-rebuild = "nixos-rebuild --sudo --flake ${flake}";
          }
        ]
        ++ aliases);
  };
}
