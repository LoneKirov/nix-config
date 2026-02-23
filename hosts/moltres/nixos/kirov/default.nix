{config, ...}: {
  sops.secrets.kirov_hashed_password = {
    format = "yaml";
    sopsFile = ./password.sops.yaml;
    key = "hashed";
  };

  users.users.kirov.hashedPasswordFile = config.sops.secrets.kirov_hashed_password.path;
}
