{config, ...}: {
  sops.secrets.harmonia = {
    format = "yaml";
    sopsFile = ./harmonia.sops.yaml;
    key = "secret";
  };
  services.harmonia.cache = {
    enable = true;

    signKeyPaths = [config.sops.secrets.harmonia.path];
  };
}
