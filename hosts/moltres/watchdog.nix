# moltres is headless, so without these a hung or panicked kernel stays down
# until someone power cycles it.
let
  timeout = "30s";
in {
  boot = {
    # iTCO_wdt is the chipset watchdog, and i2c_i801 creates its device. udev
    # would otherwise load both partway through coldplug, leaving a hang in the
    # drivers probed before them uncovered. Loading them first also makes
    # iTCO_wdt /dev/watchdog0, the device systemd opens; intel_oc_wdt takes
    # that number when udev gets to it first.
    initrd = {
      kernelModules = ["i2c_i801" "iTCO_wdt"];
      systemd.settings.Manager.RuntimeWatchdogSec = timeout;
    };

    # Lockups become panics, so efi_pstore saves the kernel log to firmware
    # storage before the reboot, and systemd-pstore archives it to
    # /var/lib/systemd/pstore on the next boot.
    kernelParams = ["softlockup_panic=1" "nmi_watchdog=panic" "panic=10"];
  };
  systemd.settings.Manager.RuntimeWatchdogSec = timeout;
}
