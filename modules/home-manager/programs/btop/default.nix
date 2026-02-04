{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config.xdg) configHome;
in {
  programs = {
    btop.enable = lib.mkDefault true;
    matugen.config.templates.btop = {
      input_path = ./btop.theme.toml;
      output_path = "${configHome}/btop/themes/matugen.theme";
      post_hook = "${lib.getExe' pkgs.procps "pkill"} -SIGUSR2 btop";
    };
  };
}
