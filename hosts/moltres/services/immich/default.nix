{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.immich;
  domain = "immich.kanto.casa";
  oauthSecret = key: {
    format = "yaml";
    sopsFile = ./immich.sops.yaml;
    inherit key;
  };
in {
  sops.secrets = {
    immich-oauth-client-id = oauthSecret "client_id";
    immich-oauth-client-secret = oauthSecret "client_secret";
  };

  services = {
    immich = {
      enable = true;
      host = "0.0.0.0";
      mediaLocation = "/srv/immich";
      accelerationDevices = ["/dev/dri/renderD128"];
      # the same weights in immich's newer exports; its machine learning service
      # treats the default `main` ones as legacy
      machine-learning.environment.MACHINE_LEARNING_MODEL_REVISION = "v2";
      # immich's admin settings page is read-only while these are set
      settings = {
        server.externalDomain = "https://${domain}";
        # moltres's UHD 630 only gets Quick Sync through Intel's discontinued
        # Media SDK
        ffmpeg.accel = "vaapi";
        # the best search recall for its speed in immich's CLIP benchmarks; the
        # larger models cost 4-10x the CPU time for about a point more
        machineLearning.clip.modelName = "ViT-B-16-SigLIP2__webli";
        oauth = {
          enabled = true;
          issuerUrl = "https://pocket-id.kanto.casa";
          clientId._secret = config.sops.secrets.immich-oauth-client-id.path;
          clientSecret._secret = config.sops.secrets.immich-oauth-client-secret.path;
          buttonText = "Login with Pocket ID";
        };
      };
    };

    # the tuning from immich's own postgres image, in its SSD variant since the
    # database lives on the NVMe
    # https://github.com/immich-app/base-images/blob/main/postgres/postgresql.ssd.conf
    postgresql.settings = {
      shared_buffers = "512MB";
      work_mem = "16MB";
      max_wal_size = "5GB";
      wal_compression = true;
      autovacuum_vacuum_scale_factor = 0.1;
      autovacuum_analyze_scale_factor = 0.05;
      autovacuum_vacuum_cost_limit = 1000;
      effective_io_concurrency = 200;
      random_page_cost = 1.2;
    };

    # immich signs in through Pocket ID itself; Caddy's login would stop the
    # mobile app and shared links
    caddy-podman.virtualHosts.${domain} = ''
      reverse_proxy host.containers.internal:${toString cfg.port}
    '';
  };

  # OpenVINO moves machine learning onto any GPU it can see, and on the UHD 630
  # it ran slower there than on the CPU; transcoding and Plex share the GPU too
  systemd.services.immich-machine-learning.serviceConfig.PrivateDevices = lib.mkForce true;
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      # OpenCL for tone mapping HDR video; Intel's current compute runtime
      # dropped this GPU generation
      intel-compute-runtime-legacy1
    ];
  };

  # owned as the units' StateDirectory= and CacheDirectory= leave them: a
  # switch reapplies these tmpfiles rules but doesn't restart the services, so
  # root-owned defaults lock them out of their own directories
  persist.directories = [
    {
      directory = "/var/lib/redis-immich";
      inherit (config.services.redis.servers.immich) user group;
      mode = "0700";
    }
    {
      directory = "/var/cache/immich"; # downloaded models, so a reboot doesn't fetch them again
      inherit (cfg) user group;
    }
  ];

  networking.firewall.interfaces.${config.lib.quadlet.bridgeInterfaces}.allowedTCPPorts = [cfg.port];
}
