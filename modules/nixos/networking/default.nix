{
  config,
  lib,
  ...
}: let
  isWSL = config.host.wsl;
in {
  imports = [
    ./tailscale.nix
  ];

  config = {
    networking = {
      networkmanager.enable = lib.mkDefault (! isWSL);
      nftables.enable = lib.mkDefault true;
    };
    persist.directories = lib.mkIf config.networking.networkmanager.enable [
      "/etc/NetworkManager/system-connections" # NM connections
    ];
  };
}
