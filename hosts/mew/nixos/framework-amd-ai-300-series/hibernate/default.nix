{
  lib,
  pkgs,
  ...
}: {
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

  # Hibernate is broken on kernels >6.17.9 and <6.19
  # https://bugzilla.kernel.org/show_bug.cgi?id=220858
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_testing;
}
