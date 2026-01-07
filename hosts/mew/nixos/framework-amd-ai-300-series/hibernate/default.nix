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

  boot = {
    # Hibernate is broken on kernels >6.17.9
    # https://bugzilla.kernel.org/show_bug.cgi?id=220858
    kernelPackages = lib.mkForce (pkgs.linuxPackagesFor (pkgs.linux_6_17.override {
      argsOverride = rec {
        src = pkgs.fetchurl {
          url = "mirror://kernel/linux/kernel/v6.x/linux-${version}.tar.xz";
          sha256 = "sha256-bQiAO5U8UJ30jUTTKB7TklJDIdi7NT6yHAVVeQyPjgY=";
        };
        version = "6.17.9";
        modDirVersion = "6.17.9";
      };
    }));
  };
}
