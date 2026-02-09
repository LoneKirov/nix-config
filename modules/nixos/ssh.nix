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
  environment.etc = let
    pm = config.impermanence.persistentMountpoint;
  in {
    "ssh/ssh_host_rsa_key".source = "${pm}/etc/ssh/ssh_host_rsa_key";
    "ssh/ssh_host_rsa_key.pub".source = "${pm}/etc/ssh/ssh_host_rsa_key.pub";
    "ssh/ssh_host_ecdsa_key".source = "${pm}/etc/ssh/ssh_host_ecdsa_key";
    "ssh/ssh_host_ecdsa_key.pub".source = "${pm}/etc/ssh/ssh_host_ecdsa_key.pub";
    "ssh/ssh_host_ed25519_key".source = "${pm}/etc/ssh/ssh_host_ed25519_key";
    "ssh/ssh_host_ed25519_key.pub".source = "${pm}/etc/ssh/ssh_host_ed25519_key.pub";
  };
}
