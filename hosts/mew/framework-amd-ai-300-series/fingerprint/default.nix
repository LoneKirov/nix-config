{pkgs, ...}: {
  # The driver erases every stored print when listing them fails while opening
  # the sensor, even when the failure is a USB error such as the sensor timing
  # out or dropping off the bus after resume.
  services.fprintd.package = pkgs.fprintd.override {
    libfprint = pkgs.libfprint.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or []) ++ [./goodixmoc-keep-prints-on-transport-error.patch];
    });
  };
}
