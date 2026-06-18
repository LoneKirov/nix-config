{
  config,
  inputs,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  xserver = osConfig.services.xserver.enable or false;
in {
  config.programs.starship = let
    jujutsu = config.programs.jujutsu.enable;
    system = pkgs.stdenv.hostPlatform.system;
    jj-starship = "${lib.getExe inputs.jj-starship.packages.${system}.jj-starship}";
  in {
    enable = lib.mkDefault true;
    presets = ["nerd-font-symbols"];
    settings = lib.mkMerge [
      {
        "$schema" = "https://starship.rs/config-schema.json";
        direnv.disabled = false;
        hostname.ssh_only = xserver;
      }
      (lib.mkIf jujutsu {
        custom.jj = {
          when = "${jj-starship} detect";
          shell = [jj-starship];
          format = "$output ";
        };
        git_branch.disabled = true;
        git_status.disabled = true;
      })
    ];
  };
}
