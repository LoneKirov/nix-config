{pkgs, ...}: {
  # https://github.com/systemd/systemd/issues/38193
  system.replaceDependencies.replacements = with pkgs; [
    {
      oldDependency = systemd;
      newDependency = systemd.overrideAttrs (oldAttrs: {
        patches = oldAttrs.patches ++ [./fix-suspend-then-hibernate.patch];
      });
    }
  ];
  services.logind.settings.Login.HandleLidSwitch = "suspend-then-hibernate";
  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "3h";
  };
}
