{
  config,
  lib,
  ...
}: {
  config = lib.mkIf (config.host.ssh && ! config.host.gui) {
    # sudo authenticates with a key from the forwarded ssh agent
    security.pam = {
      rssh = {
        enable = true;
        settings.auth_key_file = "/etc/ssh/authorized_keys.d/$ruser";
      };
      services.sudo.rssh = true;
    };
  };
}
