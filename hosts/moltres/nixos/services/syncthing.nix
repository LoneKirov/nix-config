{...}: {
  services.syncthing = {
    enable = true;
    user = "kirov";
    group = "users";
    dataDir = "/srv/syncthing";
    overrideDevices = false;
    overrideFolders = false;
  };
}
