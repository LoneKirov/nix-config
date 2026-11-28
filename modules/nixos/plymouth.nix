{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  theme = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.plymouth-nixos-chase;
in {
  config = lib.mkIf config.host.gui {
    boot.plymouth = {
      enable = lib.mkDefault true;
      # the theme's name follows its build settings (a glitch build adds -glitch)
      theme = lib.mkDefault (lib.removePrefix "plymouth-theme-" theme.pname);
      themePackages = [theme];
    };
  };
}
