_: {
  nix.settings = {
    # never build locally; CI builds slowpoke and uploads it to cache.kanto.casa
    max-jobs = 0;
    min-free = 1024 * 1024 * 1024;
    max-free = 4096 * 1024 * 1024;
  };
}
