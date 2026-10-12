{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [inputs.nix-index-database.nixosModules.default];

  config = {
    programs = {
      nix-index-database.comma.enable = lib.mkDefault true;
      # https://github.com/nix-community/nix-index-database/issues/179
      # the command-not-found hook searches the full database on every
      # mistyped command, which takes over a second
      nix-index = {
        enableBashIntegration = lib.mkDefault false;
        enableFishIntegration = lib.mkDefault false;
        enableZshIntegration = lib.mkDefault false;
      };
    };
    environment.systemPackages = lib.mkIf config.programs.nix-index-database.comma.enable [
      # takes priority over the ,.fish comma ships, which it sources
      (lib.hiPrio inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.comma-fish-completion)
    ];
  };
}
