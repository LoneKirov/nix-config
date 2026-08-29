_: {
  services.syncthing = {
    enable = true;
    user = "kirov";
    group = "users";
    dataDir = "/srv/syncthing";
    overrideDevices = false;
    overrideFolders = false;
    guiAddress = "0.0.0.0:8384";
    settings.options.alwaysLocalNets = [
      "100.64.0.0/10"
      "fd7a:115c:a1e0::/48"
    ];
  };

  services.caddy-podman.virtualHosts."syncthing.moltres.kanto.casa" = ''
    import reverse_proxy_with_auth host.containers.internal:8384
  '';
}
