{...}: {
  boot = {
    kernelParams = [
      "zswap.enabled=1" # enable zswap
      "zswap.max_pool_percent=25" # limit zswap to 20% of RAM
      "zswap.shrinker_enabled=1" # shrink the pool proactively on memory pressure
    ];
  };
}
