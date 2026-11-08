{pkgs, ...}: {
  # The RTC alarm can resume mew a fraction of a second before HibernateDelaySec
  # runs out. systemd only checks whether its timer has already fired, takes
  # the early resume for a manual wakeup and stays awake.
  # https://github.com/systemd/systemd/issues/38193
  # https://github.com/systemd/systemd/pull/44650, backported to v262
  system.replaceDependencies.replacements = with pkgs; [
    {
      oldDependency = systemd;
      newDependency = systemd.overrideAttrs (oldAttrs: {
        patches = oldAttrs.patches ++ [./sleep-wait-for-timer-about-to-expire.patch];
      });
    }
  ];
  services.logind.settings.Login.HandleLidSwitch = "suspend-then-hibernate";
  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "3h";
  };
}
