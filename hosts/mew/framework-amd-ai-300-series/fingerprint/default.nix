{
  config,
  lib,
  pkgs,
  ...
}: let
  pamExec = "${config.security.pam.package}/lib/security/pam_exec.so";
in {
  # Skip pam_fprintd while the lid is closed.
  #
  # The lid is checked in PAM on every attempt because keeping fprintd from
  # running breaks DMS: it looks for a reader with fprintd-list when it starts,
  # and if fprintd is down then, its lock screen has no fingerprint until DMS
  # restarts or its lock screen settings are opened.
  #
  # Declaring the option again merges this submodule into every PAM service,
  # including ones other modules define. Inside it, `config` is that service's
  # config, so pamExec has to be bound outside. Building security.pam.services
  # from config.security.pam.services would recurse forever, because its
  # attribute names would depend on its own result.
  #
  # DMS's lock screen isn't covered. It runs fingerprint from its own PAM file,
  # alongside the password prompt, so a closed lid doesn't hold it up.
  options.security.pam.services = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule ({config, ...}: {
      # Services with useDefaultRules off, such as greetd, have no fprintd rule
      # even though fprintAuth is on.
      config.rules.auth.fprintd-lid-closed = lib.mkIf (config.useDefaultRules && config.fprintAuth) {
        # success=1 skips exactly one line, so this rule has to sit directly
        # before fprintd. If grep can't read the lid, the rule is ignored and
        # fingerprint stays on.
        order = config.rules.auth.fprintd.order - 1;
        control = "[success=1 default=ignore]";
        modulePath = pamExec;
        # pam_exec reports every non-zero exit, which here means every prompt
        # with the lid open. quiet hides it from the prompt, quiet_log from the
        # journal.
        args = ["quiet" "quiet_log" (lib.getExe pkgs.gnugrep) "-q" "closed" "/proc/acpi/button/lid/LID0/state"];
      };
    }));
  };

  # The driver erases every stored print when listing them fails while opening
  # the sensor, even when the failure is a USB error such as the sensor timing
  # out or dropping off the bus after resume.
  config.services.fprintd.package = pkgs.fprintd.override {
    libfprint = pkgs.libfprint.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or []) ++ [./goodixmoc-keep-prints-on-transport-error.patch];
    });
  };
}
