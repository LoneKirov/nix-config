{...}: {
  services.beszel.hub = {
    enable = true;
    host = "0.0.0.0";
  };

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
}
