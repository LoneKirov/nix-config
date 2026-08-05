{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config.user) username;
  user = config.users.users.${username};
  cfg = config.nixremote;
  nixremote = cfg.user.username;
in {
  options = let
    inherit (lib) types;
  in {
    nixremote = {
      user = {
        enable = lib.mkEnableOption "nixremote user";
        username = lib.mkOption {
          type = types.nonEmptyStr;
          default = "nixremote";
          readOnly = true;
        };
      };
      sshKey = lib.mkOption {
        type = types.nonEmptyStr;
        default = builtins.readFile ../../../keys/nixremote.pub;
        readOnly = true;
      };
      enablePrivateKey = lib.mkEnableOption "nixremote privatae key";
    };
  };

  config = lib.mkMerge [
    {
      nixremote.user.enable = lib.mkDefault (! config.services.xserver.enable);
    }
    (lib.mkIf cfg.user.enable {
      users = {
        users.${nixremote} = {
          isSystemUser = true;
          home = "/var/lib/${nixremote}";
          createHome = true;
          group = nixremote;
          extraGroups = ["wheel"];
          shell = "${lib.getExe pkgs.bash}";

          openssh.authorizedKeys.keys = user.openssh.authorizedKeys.keys ++ [cfg.sshKey];
        };
        groups.${nixremote} = {};
      };

      systemd.tmpfiles.rules = [
        "d /var/lib/${nixremote} 0750 ${nixremote} ${nixremote}"
        "d /var/lib/${nixremote}/.ssh 0700 ${nixremote} ${nixremote}"
      ];

      nix.settings.trusted-users = [nixremote];
    })
    (lib.mkIf cfg.enablePrivateKey {
      sops.secrets.nixremote_ssh_key = {
        format = "yaml";
        sopsFile = ./nixremote.sops.yaml;
        key = "ssh_key";
      };
    })
  ];
}
