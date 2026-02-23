{config, ...}: {
  imports = [
    ./steam.nix
    ./vicinae.nix
  ];

  sops.secrets.kirov_hashed_password = {
    format = "yaml";
    sopsFile = ./password.sops.yaml;
    key = "hashed";
  };

  local.kirov.nixos.hashedPasswordFile = config.sops.secrets.kirov_hashed_password.path;
}
