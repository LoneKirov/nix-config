{lib, ...}: {
  boot.lanzaboote.measuredBoot = {
    # https://github.com/nix-community/lanzaboote/pull/564#issuecomment-41896858291
    upstreamStaticMeasurements = lib.mkForce [
      "500-separator.pcrlock.d/300-0x00000000.pcrlock"
      "400-secureboot-separator.pcrlock.d/300-0x00000000.pcrlock"
    ];
    pcrs = lib.mkForce [
      # 0 # platform-code
      # 1 # platform-config
      # 2 # external-code
      # 3 # external-config
      4 # boot-loader-code
      7 # secure-boot-policy
    ];
  };
}
