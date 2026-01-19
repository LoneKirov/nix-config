{...}: {
  imports = [./services];

  config = {
    services = {
      caddy.enable = true;
      glances = {
        enable = true;
        config = ''
          [fs]
          hide = /boot/grub2/.*,/boot/writable,.*/.snapshots.*,/etc.*,/home,/home/kirov/.*,/mnt.*,/nix,/opt,/root,/usr.*,/var/.*,/srv
          [diskio]
          hide = loop.*,/dev/loop.*
        '';
      };
      keybase.enable = true;
      plex.enable = true;
      resilio-sync.enable = true;
      torrents.enable = true;
    };
  };
}
