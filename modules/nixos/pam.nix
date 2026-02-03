{
  config,
  lib,
  ...
}: {
  config = lib.mkIf (! config.services.xserver.enable) {
    # enable sudo from ssh key if this is a headless system
    security.pam = {
      rssh = {
        enable = true;
        settings.auth_key_file = "/etc/ssh/authorized_keys.d/$ruser";
      };
      services.sudo.rssh = true;
    };
  };
}
