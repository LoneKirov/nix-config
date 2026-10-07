{
  config,
  lib,
  pkgs,
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
  networking.firewall.interfaces.${config.lib.quadlet.bridgeInterfaces}.allowedTCPPorts = [5000];

  # CI pushes its builds into the store harmonia serves; the key can only
  # speak the nix daemon protocol and only from the tailnet
  users = {
    users.nixremote = {
      isSystemUser = true;
      home = "/var/lib/nixremote";
      createHome = true;
      group = "nixremote";
      shell = "${lib.getExe pkgs.bash}";
      openssh.authorizedKeys.keys = [
        ''restrict,command="${config.nix.package}/bin/nix-daemon --stdio",from="100.64.0.0/10,fd7a:115c:a1e0::/48" ${lib.trim (builtins.readFile ../../../../keys/github.pub)}''
      ];
    };
    groups.nixremote = {};
  };
  nix.settings.trusted-users = ["nixremote"];

  # disable detnix automatic gc to make better use of store as cache
  environment.etc."determinate/config.json".text = ''
    {
      "garbageCollector": {
        "strategy": "disabled"
      }
    }
  '';
  # delete old generations, but leave collection to min-free below so
  # harmonia's cached paths aren't wiped weekly
  programs.nh.clean.extraArgs = "--keep-since 14d --keep 5 --no-gc";
  nix.settings = {
    min-free = 100 * 1024 * 1024 * 1024;
    max-free = 200 * 1024 * 1024 * 1024;
  };
}
