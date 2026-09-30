{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption types;
  hostType = types.submodule ({config, ...}: {
    options = {
      gui = mkOption {
        type = types.bool;
        default = false;
        description = "Runs a graphical session.";
      };
      wsl = mkOption {
        type = types.bool;
        default = false;
        description = "Runs under WSL.";
      };
      ssh = mkOption {
        type = types.bool;
        default = ! config.gui && ! config.wsl;
        description = "Runs sshd; other hosts get ssh config for it.";
      };
    };
  });
in {
  options = {
    hosts = mkOption {
      type = types.attrsOf hostType;
      readOnly = true;
      description = "Every host in the flake.";
    };
    host = mkOption {
      type = hostType;
      readOnly = true;
      default = config.hosts.${config.networking.hostName};
      description = "This host's entry in `hosts`.";
    };
  };
}
