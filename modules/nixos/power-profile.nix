_: {
  services.tuned = {
    enable = true;
    ppdSupport = true;
  };

  services.power-profiles-daemon.enable = false;
}
