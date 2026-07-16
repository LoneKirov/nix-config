{
  config,
  lib,
  ...
}: let
  isWSL = config.wsl.enable or false;
in {
  config = lib.mkIf (! isWSL) {
    services = {
      openssh = {
        # enable ssh if this is a headless system
        enable = lib.mkDefault (! config.services.xserver.enable);
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
          PermitRootLogin = "no";
        };
      };
      # make it easier to use other agents
      gnome.gcr-ssh-agent.enable = lib.mkDefault false;
    };
  };
}
