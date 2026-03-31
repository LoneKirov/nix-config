{...}: {
  imports = [
    ./tailscale.nix
  ];

  config.networking.networkmanager.enable = true;
}
