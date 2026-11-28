{
  config,
  lib,
  ...
}: let
  workaround = ../nixos/networking/facter-dhcp.nix;
  runsDhcpcd = nixos: let
    inherit (nixos.config) networking;
  in
    networking.dhcpcd.enable
    && (networking.useDHCP || lib.any (i: i.useDHCP == true) (lib.attrValues networking.interfaces));
  affected = lib.filterAttrs (_: nixos:
    nixos.config.networking.networkmanager.enable && nixos.config.hardware.facter.enable)
  config.flake.nixosConfigurations;
  stillRunning = lib.attrNames (lib.filterAttrs (_: runsDhcpcd) affected);
  fixedUpstream = lib.attrNames (lib.filterAttrs (_: nixos:
    ! runsDhcpcd (nixos.extendModules {modules = [{disabledModules = [workaround];}];}))
  affected);
in {
  # fails if dhcpcd runs beside NetworkManager on a facter host, and also once
  # facter would no longer start it there without the workaround, so the
  # workaround doesn't outlive the bug
  perSystem = {pkgs, ...}: {
    checks.facter-dhcp = pkgs.runCommand "facter-dhcp" {} ''
      ${lib.optionalString (stillRunning != []) ''
        echo "dhcpcd runs beside NetworkManager on: ${toString stillRunning}" >&2
        exit 1
      ''}
      ${lib.optionalString (fixedUpstream != []) ''
        echo "facter no longer starts dhcpcd beside NetworkManager on ${toString fixedUpstream}; remove modules/nixos/networking/facter-dhcp.nix" >&2
        exit 1
      ''}
      touch $out
    '';
  };
}
