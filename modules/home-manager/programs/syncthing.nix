{
  lib,
  osConfig,
  ...
}: let
  gui = osConfig.host.gui or false;
in {
  services.syncthing = {
    enable = lib.mkDefault gui;
    overrideDevices = false;
    overrideFolders = false;
    settings.options.alwaysLocalNets = [
      "100.64.0.0/10"
      "fd7a:115c:a1e0::/48"
    ];
  };
}
