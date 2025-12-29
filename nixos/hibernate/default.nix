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
  # use suspend-then-hibernate when closing the lid
  services.logind.settings.Login.HandleLidSwitch = "suspend-then-hibernate";
}
