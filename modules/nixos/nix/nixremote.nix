{
  config,
  lib,
  pkgs,
  ...
}: {
  config =
    lib.mkIf (! config.services.xserver.enable)
    (let
      nixremote = "nixremote";
    in {
      users = {
        users.${nixremote} = {
          isSystemUser = true;
          home = "/var/lib/${nixremote}";
          createHome = true;
          group = nixremote;
          extraGroups = ["wheel"];
          shell = "${lib.getExe pkgs.bash}";

          openssh.authorizedKeys.keys =
            config.local.user.nixos.openssh.authorizedKeys.keys
            ++ [
              (builtins.readFile ../../../keys/nixremote.pub)
            ];
        };
        groups.${nixremote} = {};
      };

      systemd.tmpfiles.rules = [
        "d /var/lib/${nixremote} 0750 ${nixremote} ${nixremote}"
        "d /var/lib/${nixremote}/.ssh 0700 ${nixremote} ${nixremote}"
      ];

      nix.settings.trusted-users = [nixremote];

      sops.secrets.nixremote_ssh_key = {
        format = "yaml";
        sopsFile = ./nixremote.sops.yaml;
        key = "ssh_key";
      };
    });
}
