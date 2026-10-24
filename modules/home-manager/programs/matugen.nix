{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  tomlFormat = pkgs.formats.toml {};
  matugenConfig = {config = {};} // config.programs.matugen.config;
  dux-shell = osConfig.programs.dux-shell.enable or false;
  matugen = config.programs.matugen.enable;
in {
  options.programs.matugen = {
    enable = lib.mkEnableOption "matugen" // {default = dux-shell;};
    config = lib.mkOption {
      inherit (tomlFormat) type;
      default = {};
      description = ''
        Settings written as TOML to {file}`~/.config/matugen/config.toml`
      '';
    };
  };

  config.xdg.configFile = lib.mkIf matugen {
    "matugen/config.toml".source = tomlFormat.generate "matugen-config" matugenConfig;
  };
}
