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

  # disable detnix automatic gc to make better use of store as cache
  environment.etc."determinate/config.json".text = ''
    {
      "garbageCollector": {
        "strategy": "disabled"
      }
    }
  '';
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
}
