{config, ...}: {
  services.openssh = {
    # enable ssh if this is a headless system
    enable = ! config.services.xserver.enable;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
    hostKeys = [
      {
        type = "ed25519";
        path = "${config.impermanence.persistentMountpoint}/etc/ssh/ssh_host_ed25519_key";
      }
      {
        type = "ecdsa";
        path = "${config.impermanence.persistentMountpoint}/etc/ssh/ssh_host_ecdsa_key";
      }
      {
        type = "rsa";
        path = "${config.impermanence.persistentMountpoint}/etc/ssh/ssh_host_rsa_key";
      }
    ];
  };
}
