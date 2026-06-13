{...}: {
  services.beszel.agent.environment.EXTRA_FILESYSTEMS = ''
    /srv/root__main,/srv/storage__storage,/srv/backup__backup
  '';
}
