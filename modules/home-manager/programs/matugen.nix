{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  tomlFormat = pkgs.formats.toml {};
  matugenConfig = {config = {};} // config.programs.matugen.config;
  dms-shell = osConfig.programs.dms-shell.enable or false;
  matugen = config.programs.matugen.enable;
in {
  options.programs.matugen = {
    enable = lib.mkEnableOption "matugen" // {default = dms-shell;};
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
