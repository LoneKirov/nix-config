_: {
  services.xserver.videoDrivers = ["nvidia"];
  hardware = {
    graphics.enable = true;
    nvidia = {
      open = true;
      modesetting.enable = true;
      powerManagement.enable = true;
    };
  };
  # the nixos nvidia module only loads these when services.xserver.enable is set,
  # but niri needs nvidia_drm for kms. Loading them in the initrd gives plymouth
  # the nvidia outputs from the start
  boot.initrd.kernelModules = [
    "nvidia"
    "nvidia_modeset"
    "nvidia_drm"
  ];
}
