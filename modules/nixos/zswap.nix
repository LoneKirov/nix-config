{
  config,
  lib,
  ...
}: {
  # zswap would compress pages a second time on their way into zram
  boot.kernelParams = lib.mkIf (! config.zramSwap.enable) [
    "zswap.enabled=1"
    "zswap.max_pool_percent=25"
    "zswap.shrinker_enabled=1" # shrink the pool proactively on memory pressure
  ];
}
