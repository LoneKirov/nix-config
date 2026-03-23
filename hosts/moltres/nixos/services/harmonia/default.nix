{config, ...}: {
  sops.secrets.harmonia = {
    format = "dotenv";
    sopsFile = ./harmonia.sops.env;
    key = "secret";
  };
  services.harmonia.cache = {
    enable = true;

    signKeyPaths = [config.sops.secrets.harmonia.path];
  };
}
