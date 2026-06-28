{
  config,
  lib,
  ...
}: {
  services = {
    openssh = {
      # enable ssh if this is a headless system
      enable = ! config.services.xserver.enable;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
      };
    };
    # make it easier to use other agents
    gnome.gcr-ssh-agent.enable = lib.mkDefault false;
  };
}
