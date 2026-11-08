# slowpoke is headless and reboots itself for new kernels, so without this a
# hung or panicked kernel stays down until someone power cycles it.
let
  # The Pi's watchdog only counts to about 15s, but the kernel pings it while
  # systemd keeps pinging within this timeout. A minute leaves room for systemd
  # to stall while the Pi swaps hard.
  timeout = "1min";
in {
  boot.initrd.systemd.settings.Manager.RuntimeWatchdogSec = timeout;
  systemd.settings.Manager.RuntimeWatchdogSec = timeout;
}
