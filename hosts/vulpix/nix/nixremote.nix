{config, ...}: let
  nixremote = "nixremote";
  sshKey = builtins.readFile ../../../keys/nixremote.pub;
  inherit (config.users.users) kirov;
in {
  config = {
    users = {
      users.${nixremote} = {
        uid = 450;
        isHidden = true;
        home = "/Users/${nixremote}";
        createHome = true;

        openssh.authorizedKeys.keys = kirov.openssh.authorizedKeys.keys ++ [sshKey];
      };
      knownUsers = [nixremote];
    };

    nix.settings.trusted-users = [nixremote];
  };
}
