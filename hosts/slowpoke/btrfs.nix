_: {
  services.beesd.filesystems.root = {
    spec = "/srv/root";
    hashTableSizeMB = 128;
    extraOptions = ["--loadavg-target=1.0"];
  };
}
