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
      # pin every ssh host's key; CI checks each against its age recipient in .sops.yaml
      programs.ssh.knownHosts = lib.mapAttrs (name: _: {
        hostNames = [name "${name}.lan"];
        publicKeyFile = ../../keys/${name}.pub;
      }) (lib.filterAttrs (_: host: host.ssh) config.hosts);
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
