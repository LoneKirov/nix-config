_: {
  services.beesd.filesystems.root = {
    spec = "/srv/root";
    hashTableSizeMB = 256;
    extraOptions = ["--loadavg-target=4.0"];
  };
}
