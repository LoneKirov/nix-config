{
  lib,
  pkgs,
  ...
}: {
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    # On a tmpfs root, /tmp would share root's size limit, so filling it would
    # leave activation no room to rewrite /etc. On WSL it keeps temporary files
    # out of the distro's VHDX. Nix builds in /nix/var/nix/builds, so /tmp's
    # limit doesn't cap builds
    tmp.useTmpfs = lib.mkDefault true;
  };
}
