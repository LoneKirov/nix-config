{
  lib,
  osConfig,
  ...
}: let
  # hosts that can push to the kanto cache declare this secret
  tokenFile = osConfig.sops.secrets.attic-token.path or null;
in {
  config = lib.mkIf (tokenFile != null) {
    programs.attic-client = {
      enable = lib.mkDefault true;
      settings = {
        default-server = "kanto";
        servers.kanto = {
          endpoint = "https://attic.kanto.casa/";
          token-file = tokenFile;
        };
      };
      watchStore = ["kanto"];
    };
    # pushing everything isn't worth it away from home, so watch-store only
    # runs when started: systemctl --user start attic-watch-store--kanto
    systemd.user.services."attic-watch-store--kanto".Install.WantedBy = lib.mkForce [];
  };
}
