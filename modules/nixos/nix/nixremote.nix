{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config.user) username;
  user = config.users.users.${username};
  nixremote = "nixremote";
  inherit (config.nixremote) sshKey;
in {
  options = let
    inherit (lib) types;
  in {
    nixremote.sshKey = lib.mkOption {
      type = types.nonEmptyStr;
      default = builtins.readFile ../../../keys/nixremote.pub;
      readOnly = true;
    };
  };

  config = lib.mkIf (! config.services.xserver.enable) {
    users = {
      users.${nixremote} = {
        isSystemUser = true;
        home = "/var/lib/${nixremote}";
        createHome = true;
        group = nixremote;
        extraGroups = ["wheel"];
        shell = "${lib.getExe pkgs.bash}";

        openssh.authorizedKeys.keys = user.openssh.authorizedKeys.keys ++ [sshKey];
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
  };
}
