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

  config.networking.networkmanager.enable = lib.mkDefault (! isWSL);
}
