{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.glances;
  inherit (pkgs) glances;
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
in
{
  options.services.glances = {
    enable = mkEnableOption "glances";
    config = mkOption {
      type = types.str;
      default = "";
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.glances = {
      Unit = {
        Description = "Glances system monitor";
        After = "network.target";
      };

      Service =
        let
          configFile = pkgs.writeTextFile {
            name = "glances.conf";
            text = cfg.config;
          };
        in
        {
          ExecStart = "${glances}/bin/glances -C ${configFile} -w";
          Restart = "always";
          RemainAfterExit = "no";
        };

      Install.WantedBy = [ "default.target" ];
    };

    home.packages = [ glances ];
  };
}
