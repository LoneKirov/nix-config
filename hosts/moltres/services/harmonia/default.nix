{
  config,
  lib,
  ...
}: {
  sops.secrets.harmonia = {
    format = "yaml";
    sopsFile = ./harmonia.sops.yaml;
    key = "secret";
  };
  services.harmonia.cache = {
    enable = true;

    signKeyPaths = [config.sops.secrets.harmonia.path];
  };
  services.caddy-podman.virtualHosts."cache.kanto.casa" = ''
    reverse_proxy host.containers.internal:5000
  '';

  # disable detnix automatic gc to make better use of store as cache
  environment.etc."determinate/config.json".text = ''
    {
      "garbageCollector": {
        "strategy": "disabled"
      }
    }
  '';
  system.autoUpgrade.runGarbageCollection = lib.mkForce false;
  nix.extraOptions = ''
    min-free = ${toString (100 * 1024 * 1024 * 1024)}
    max-free = ${toString (200 * 1024 * 1024 * 1024)}
  '';
}
