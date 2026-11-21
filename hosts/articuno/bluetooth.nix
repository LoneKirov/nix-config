{pkgs, ...}: {
  hardware.bluetooth.enable = true;

  # btmtk loads the MT7927's Bluetooth (MT6639) firmware from this path, but
  # linux-firmware doesn't ship the blob until MediaTek approves redistributing it.
  # https://gitlab.com/kernel-firmware/linux-firmware/-/merge_requests/946
  hardware.firmware = [
    (pkgs.runCommand "mt7927-bluetooth-firmware" {} ''
      install -Dm444 ${pkgs.fetchurl {
        url = "https://gitlab.com/kernel-firmware/linux-firmware/-/raw/77ad2a92acf2ac3e5ea47432b43d925ff99db909/mediatek/mt7927/BT_RAM_CODE_MT6639_2_1_hdr.bin";
        hash = "sha256-ZpxcmaDFnIXBKF09G4sxkVwtMTQaIkT07dy/1g/7vHY=";
      }} $out/lib/firmware/mediatek/mt7927/BT_RAM_CODE_MT6639_2_1_hdr.bin
    '')
  ];
}
