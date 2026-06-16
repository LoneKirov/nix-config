{config, ...}: {
  sops.secrets.kirov_hashed_password = {
    format = "yaml";
    sopsFile = ./password.sops.yaml;
    key = "hashed";
    neededForUsers = true;
  };

  local.kirov = {
    nixos.hashedPasswordFile = config.sops.secrets.kirov_hashed_password.path;
    home-manager.local.programs = {
      steam-flatpak.enable = true;
      bw.sshAgent = true;
    };
  };
}
