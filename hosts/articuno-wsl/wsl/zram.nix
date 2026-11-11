{pkgs, ...}: {
  # zramSwap can't work here: zram-generator counts WSL as a container and
  # sets nothing up
  # (https://github.com/systemd/zram-generator/blob/v1.2.1/src/generator.rs#L80),
  # and the swap unit it would generate waits on a device unit that never
  # appears, as NixOS-WSL runs without udev
  systemd.services.zram-swap = {
    description = "Swap on zram";
    wantedBy = ["multi-user.target"];
    path = [pkgs.kmod pkgs.util-linux];
    # swapoff on every switch would pull all swapped pages back into memory
    restartIfChanged = false;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    # This writes sysfs rather than using zramctl, which waits for udev to
    # initialize the device and fails without it. The WSL kernel builds zram
    # with only lzo and lzo-rle, so this keeps its lzo-rle default.
    script = ''
      modprobe zram
      mem=$(sed -n 's/^MemTotal: *\([0-9]*\) kB$/\1/p' /proc/meminfo)
      echo "$((mem / 2))K" > /sys/block/zram0/disksize
      mkswap /dev/zram0
      # WSL enables its own swap file with the default, negative priority
      swapon --priority 5 /dev/zram0
    '';
    preStop = ''
      swapoff /dev/zram0
      echo 1 > /sys/block/zram0/reset
    '';
  };
}
