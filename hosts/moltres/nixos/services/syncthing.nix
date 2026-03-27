{...}: {
  services.syncthing = {
    enable = true;
    user = "kirov";
    group = "users";
    dataDir = "/srv/syncthing";
    overrideDevices = false;
    overrideFolders = false;
    settings.options.alwaysLocalNets = [
      "100.64.0.0/10"
      "fd7a:115c:a1e0::/48"
    ];
  };
}
