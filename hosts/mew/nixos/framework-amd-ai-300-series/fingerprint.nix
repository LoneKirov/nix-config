{
  lib,
  pkgs,
  ...
}: {
  # Adapted from https://github.com/kariudo/framework-13-fingerprint-fix
  systemd.services."reset-fingerprint-reader-on-resume" = {
    environment = {
      PCI_BUS_ID = "0000:c1:00.4";
      GOODIX_USB_ID = "27c6:609c";
      XHCI_DRIVER_PATH = "/sys/bus/pci/drivers/xhci_hcd";
    };
    script = ''
      # Rebind USB controller 0000:c1:00.4 after resume to restore Goodix fingerprint reader.
      echo "<6>Checking PCI function $PCI_BUS_ID for Goodix device ID $GOODIX_USB_ID"
      sleep 1
      if ! ${lib.getExe' pkgs.usbutils "lsusb"} -d "$GOODIX_USB_ID" >/dev/null 2>&1; then
        echo "<6>Goodix missing after resume, resetting xHCI controller $PCI_BUS_ID"
        echo "$PCI_BUS_ID" >"$XHCI_DRIVER_PATH/unbind"
        sleep 1
        echo "$PCI_BUS_ID" >"$XHCI_DRIVER_PATH/bind"
        sleep 1
        ${lib.getExe' pkgs.systemd "systemctl"} try-restart fprintd.service
      else
        echo "<6>Goodix doesn't need to be reset"
      fi
    '';
    serviceConfig = {
      Type = "oneshot";
    };
    description = "Reset fingerprint reader on resume";
    wants = ["sleep.target"];
    after = ["sleep.target"];
    wantedBy = ["sleep.target"];
  };
}
