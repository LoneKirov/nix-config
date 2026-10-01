_: {
  services.beszel.hub = {
    enable = true;
    host = "0.0.0.0";
    environment = {
      DISABLE_PASSWORD_AUTH = "true";
    };
  };
  persist.directories = [
    "/var/lib/private/beszel-hub" # DynamicUser state
  ];

  services.caddy-podman.virtualHosts."beszel.kanto.casa" = ''
    request_body {
        max_size 10MB
    }
    reverse_proxy host.containers.internal:8090 {
        transport http {
            read_timeout 360s
        }
    }
  '';
  networking.firewall.interfaces."podman+".allowedTCPPorts = [8090];
}
