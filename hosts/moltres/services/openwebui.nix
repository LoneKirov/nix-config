_: {
  config = {
    services.caddy-podman.virtualHosts."openwebui.kanto.casa" = ''
      reverse_proxy vulpix.lan:8080
    '';
  };
}
