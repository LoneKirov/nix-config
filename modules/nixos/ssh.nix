{config, ...}: {
  services.openssh = {
    # enable ssh if this is a headless system
    enable = ! config.services.xserver.enable;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };
}
