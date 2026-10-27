{config, ...}: let
  port = 5000;
  cache = "kanto";
in {
  sops.secrets = {
    atticd = {
      format = "dotenv";
      sopsFile = ./atticd.sops.env;
      key = "";
    };
    # attic keeps each cache's signing key in its database. The kanto cache was
    # created with this one, so hosts trust keys/cache.pub, and recreating the
    # cache needs it again
    cache-signing-key = {
      format = "yaml";
      sopsFile = ./signing-key.sops.yaml;
      key = "secret";
    };
  };

  services.atticd = {
    enable = true;
    environmentFile = config.sops.secrets.atticd.path;
    settings = {
      listen = "[::]:${toString port}";
      api-endpoint = "https://attic.kanto.casa/";
      allowed-hosts = ["attic.kanto.casa" "cache.kanto.casa"];
      garbage-collection.default-retention-period = "1 month";
    };
  };
  # /persistent/var/lib/private/atticd is its own btrfs subvolume, so btrbk's
  # snapshots and backups of /persistent leave the cache out; CI refills it
  persist.directories = [
    "/var/lib/private/atticd" # DynamicUser state
  ];

  services.caddy-podman.virtualHosts = {
    "attic.kanto.casa" = ''
      reverse_proxy host.containers.internal:${toString port}
    '';
    # hosts substitute from the root of cache.kanto.casa, while attic serves
    # each cache under /<cache>/, so this one serves only the kanto cache
    "cache.kanto.casa" = ''
      rewrite * /${cache}{uri}
      reverse_proxy host.containers.internal:${toString port}
    '';
  };
  networking.firewall.interfaces.${config.lib.quadlet.bridgeInterfaces}.allowedTCPPorts = [port];
}
