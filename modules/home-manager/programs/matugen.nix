{
  config,
  lib,
  pkgs,
  ...
}: let
  tomlFormat = pkgs.formats.toml {};
  matugenConfig = {config = {};} // config.local.programs.matugen.config;
in {
  options.local.programs.matugen = {
    enable = lib.mkEnableOption "matugen";
    config = lib.mkOption {
      inherit (tomlFormat) type;
      default = {};
      description = ''
        Settings written as TOML to {file}`~/.config/matugen/config.toml`
      '';
    };
  };

  config = {
    local.programs.matugen.enable = lib.mkDefault config.programs.dms-shell.enable;

    xdg.configFile = lib.mkIf config.local.programs.matugen.enable {
      "matugen/config.toml".source = tomlFormat.generate "matugen-config" matugenConfig;
    };
  };
}
