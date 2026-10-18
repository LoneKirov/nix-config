{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config.networking) hostName;
  # otherwise boot and switch first build a newer nixos-rebuild from
  # <nixpkgs/nixos>, evaluating NixOS even with --store-path
  nixos-rebuild = "${config.system.build.nixos-rebuild}/bin/nixos-rebuild --no-reexec";
in {
  system.autoUpgrade = {
    enable = true;
    # after moltres's 03:00 upgrade, which can reboot the cache this pulls from
    dates = "*-*-* 05:00:00";
  };

  # Evaluating the flake takes this Pi hours of swapping, so it switches to the
  # system CI built for main's newest commit, whose path CI records on the
  # commit (see .github/workflows/nix-ci.yml). system.autoUpgrade still
  # provides the unit and its timer.
  systemd.services.nixos-upgrade.script = lib.mkForce ''
    statuses=$(${lib.getExe pkgs.curl} -fsS https://api.github.com/repos/LoneKirov/nix-config/commits/main/statuses)
    path=$(${lib.getExe pkgs.jq} -r 'map(select(.context == "system/${hostName}"))[0].description // empty' <<<"$statuses")
    if [ -z "$path" ]; then
      echo "CI hasn't recorded a ${hostName} system on main's newest commit yet"
      exit 0
    fi
    if [[ ! $path =~ ^/nix/store/[0-9a-z]{32}-nixos-system-${hostName}-[^/]+$ ]]; then
      echo "not a ${hostName} system: $path" >&2
      exit 1
    fi
    if [ "$path" = "$(readlink /run/current-system)" ]; then
      exit 0
    fi
    # signatures are checked against cache.kanto.casa's key like any substitution
    nix-store --realise "$path" >/dev/null
    ${nixos-rebuild} boot --store-path "$path"
    # reboot only for a new kernel or initrd, as allowReboot does
    booted="$(readlink /run/booted-system/{initrd,kernel,kernel-modules})"
    built="$(readlink /nix/var/nix/profiles/system/{initrd,kernel,kernel-modules})"
    if [ "$booted" = "$built" ]; then
      ${nixos-rebuild} switch --store-path "$path"
    else
      ${config.systemd.package}/bin/shutdown -r +1
    fi
  '';
}
