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
  # speak the nix daemon protocol and only from the tailnet. cache-upload isn't
  # a trusted user (that would make the key root-equivalent), so the daemon
  # only accepts paths CI signed with ci-signing.pub's secret key. Other hosts
  # don't trust that key; harmonia signs what it serves with its own
  users = {
    users.cache-upload = {
      isSystemUser = true;
      home = "/var/lib/cache-upload";
      createHome = true;
      group = "cache-upload";
      shell = "${lib.getExe pkgs.bash}";
      openssh.authorizedKeys.keys = [
        ''restrict,command="${config.nix.package}/bin/nix-daemon --stdio",from="100.64.0.0/10,fd7a:115c:a1e0::/48" ${lib.trim (builtins.readFile ../../../../keys/github.pub)}''
      ];
    };
    groups.cache-upload = {};
  };
  nix.settings.trusted-public-keys = [
    (lib.trim (builtins.readFile ../../../../keys/ci-signing.pub))
    # CI uploads whole closures, and devenv's own packages in them come from
    # devenv.cachix.org with only devenv's signature
    "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
  ];

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
