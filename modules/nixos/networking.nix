{config, ...}: {
  networking = {
    networkmanager.enable = true;
  };
  services.tailscale = {
    enable = true;
    extraSetFlags = ["--operator=${config.local.user.nixos.name}"];
  };
}
