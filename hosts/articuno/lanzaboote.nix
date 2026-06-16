{lib, ...}: {
  # https://github.com/nix-community/lanzaboote/pull/564#issuecomment-41896858291
  boot.lanzaboote.measuredBoot.upstreamStaticMeasurements = lib.mkForce [
    "500-separator.pcrlock.d/300-0x00000000.pcrlock"
    "400-secureboot-separator.pcrlock.d/300-0x00000000.pcrlock"
  ];
}
