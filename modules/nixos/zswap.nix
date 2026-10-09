_: {
  boot = {
    kernelParams = [
      "zswap.enabled=1"
      "zswap.max_pool_percent=25"
      "zswap.shrinker_enabled=1" # shrink the pool proactively on memory pressure
    ];
  };
}
