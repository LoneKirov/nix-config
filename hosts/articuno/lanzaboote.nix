{pkgs, ...}: {
  # https://github.com/nix-community/lanzaboote/issues/584
  # https://github.com/systemd/systemd/issues/40381
  systemd.services.systemd-pcrlock-secureboot-authority.enable = false;

  # Windows is on the other drive with its own ESP, but systemd-boot only lists
  # Windows Boot Manager when bootmgfw.efi is on the ESP it runs from, so
  # windows-boot-files copies Windows' boot files here. Chainloading them would
  # change the PCRs BitLocker's TPM protector is sealed to; this makes systemd-boot
  # set BootNext to the firmware's "Windows Boot Manager" entry and reboot into it
  # instead. It only does that when it finds a TPM and a BitLocker volume, and the
  # option is experimental; see loader.conf(5).
  boot.lanzaboote.settings.reboot-for-bitlocker = true;

  systemd.services.windows-boot-files = {
    description = "Copy Windows' boot files to the ESP for systemd-boot";
    wantedBy = ["multi-user.target"];
    unitConfig.RequiresMountsFor = ["/boot"];
    path = with pkgs; [jq rsync util-linux];
    serviceConfig = {
      Type = "oneshot";
      # keeps the Windows ESP mount out of the host's namespace and drops it
      # when the script exits
      PrivateMounts = true;
      PrivateTmp = true;
    };
    # Windows always boots from its own ESP, so the files there are current. It's
    # the internal ESP other than /boot that holds bootmgfw.efi.
    script = ''
      esp=c12a7328-f81f-11d2-ba4b-00a0c93ec93b
      boot=$(realpath "$(findmnt -nvo SOURCE /boot)")
      mnt=$(mktemp -d)

      set --
      for dev in $(lsblk -Jpo PATH,PARTTYPE,HOTPLUG | jq -r --arg esp "$esp" --arg boot "$boot" \
        '.blockdevices[] | recurse(.children[]?) | select(.parttype == $esp and (.hotplug | not) and .path != $boot) | .path'); do
        mount -t vfat -o ro "$dev" "$mnt" || continue
        if [ -f "$mnt/EFI/Microsoft/Boot/bootmgfw.efi" ]; then
          set -- "$@" "$dev"
        fi
        umount "$mnt"
      done

      if [ $# -ne 1 ]; then
        echo "expected one Windows ESP, found $#: $*" >&2
        exit 1
      fi

      mount -t vfat -o ro "$1" "$mnt"
      mkdir -p /boot/EFI/Microsoft
      rsync -rt --delete --modify-window=1 "$mnt/EFI/Microsoft/" /boot/EFI/Microsoft/
    '';
  };
}
