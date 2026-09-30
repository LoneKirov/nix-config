{
  config,
  lib,
  ...
}: let
  isWSL = config.host.wsl;
in {
  config = lib.mkMerge [
    {
      # normal priority so a conflicting host definition errors instead of drifting from the inventory
      services.openssh.enable = config.host.ssh;
    }
    (lib.mkIf (! isWSL) {
      services = {
        openssh.settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
          PermitRootLogin = "no";
        };
        # make it easier to use other agents
        gnome.gcr-ssh-agent.enable = lib.mkDefault false;
      };
    })
  ];
}
