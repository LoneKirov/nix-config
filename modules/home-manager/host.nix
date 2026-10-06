{
  lib,
  osConfig,
  ...
}: let
  inherit (lib) mkOption types;
in {
  # mirrors the NixOS host flags so standalone home-manager can set them
  options.host = {
    gui = mkOption {
      type = types.bool;
      default = osConfig.host.gui or false;
      description = "Runs a graphical session.";
    };
    wsl = mkOption {
      type = types.bool;
      default = osConfig.host.wsl or false;
      description = "Runs under WSL.";
    };
  };
}
