{config, ...}: let
  inherit (config.ids) uids gids;
  user = config.users.users.${config.user.username};
in {
  services.syncthing = {
    enable = true;
    dataDir = "/srv/syncthing";
    overrideDevices = false;
    overrideFolders = false;
    guiAddress = "0.0.0.0:8384";
    openDefaultPorts = true;
    settings.options.alwaysLocalNets = [
      "100.64.0.0/10"
      "fd7a:115c:a1e0::/48"
    ];
  };

  # syncthing runs as the module's own user, so it can't touch anything the
  # main user owns. This mount shows its folders to the main user as their own
  # and stores what they create there as syncthing's, so both can write without
  # shared permissions. Root isn't mapped, so use /srv/syncthing/folders as root.
  # The path can't come from users.users, which depends on fileSystems' names
  fileSystems."/home/${config.user.username}/Sync" = {
    device = "/srv/syncthing/folders";
    fsType = "none";
    options = [
      "bind"
      # on-disk id first, then the id seen through the mount
      "X-mount.idmap=u:${toString uids.syncthing}:${toString user.uid}:1 g:${toString gids.syncthing}:${toString config.users.groups.${user.group}.gid}:1"
    ];
  };

  services.caddy-podman.virtualHosts."syncthing.moltres.kanto.casa" = ''
    import reverse_proxy_with_auth host.containers.internal:8384
  '';
  networking.firewall.interfaces.${config.lib.quadlet.bridgeInterfaces}.allowedTCPPorts = [8384];
}
