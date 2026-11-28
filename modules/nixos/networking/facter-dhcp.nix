{
  config,
  lib,
  ...
}: {
  # nixpkgs' facter module turns on DHCP for each detected interface, which
  # starts dhcpcd beside NetworkManager, since NetworkManager's module only
  # turns off the global networking.useDHCP. Both clients then hold the same
  # lease, and dhcpcd 10.3.2 segfaults when NetworkManager removes the address.
  # The facter-dhcp flake check fails once nixpkgs no longer needs this
  config = lib.mkIf config.networking.networkmanager.enable {
    hardware.facter.detected.dhcp.enable = lib.mkDefault false;
  };
}
