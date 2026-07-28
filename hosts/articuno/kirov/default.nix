{config, ...}: let
  inherit (config.user) username sshKey;
  hashedPasswordFile = config.sops.secrets.kirov_hashed_password.path;
in {
  sops.secrets.kirov_hashed_password = {
    format = "yaml";
    sopsFile = ./password.sops.yaml;
    key = "hashed";
    neededForUsers = true;
  };

  users.users.${username} = {
    inherit hashedPasswordFile;
    openssh.authorizedKeys.keys = [sshKey];
  };
  home-manager.users.${username} = {
    programs.steam-flatpak.enable = true;
    services.rbw-agent.enable = true;
  };
}
