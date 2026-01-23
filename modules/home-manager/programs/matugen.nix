{
  config,
  lib,
  pkgs,
  ...
}: let
  tomlFormat = pkgs.formats.toml {};
  matugenConfig = {config = {};} // config.programs.matugen.config;
in {
  options.programs.matugen = {
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
    programs.matugen.enable = lib.mkDefault config.programs.dms-shell.enable;

    xdg.configFile = lib.mkIf config.programs.matugen.enable {
      "matugen/config.toml".source = tomlFormat.generate "matugen-config" matugenConfig;
    };
  };
}
