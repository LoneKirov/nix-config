{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config.xdg) configHome;
in {
  programs.btop.enable = lib.mkDefault true;
  local.programs.matugen.config.templates.btop = {
    input_path = ./btop.theme.toml;
    output_path = "${configHome}/btop/themes/matugen.theme";
    post_hook = pkgs.writeShellScript "matugen-btop.sh" ''
      if ${lib.getExe' pkgs.procps "pgrep"} -x "btop" > /dev/null
      then
          ${lib.getExe' pkgs.procps "pkill"} -SIGUSR2 btop
      fi
    '';
  };
}
