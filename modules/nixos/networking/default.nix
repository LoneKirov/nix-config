{
  config,
  lib,
  ...
}: let
  isWSL = config.wsl.enable or false;
in {
  imports = [
    ./tailscale.nix
  ];

  config.networking.networkmanager.enable = lib.mkDefault (! isWSL);
}
