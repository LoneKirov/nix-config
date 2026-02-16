{...}: {
  services.glances = {
    enable = true;
    extraArgs = [
      "-C"
      "${./glances.conf}"
      "-w"
    ];
  };
}
