_: {
  services.beesd.filesystems.root = {
    spec = "/srv/root";
    hashTableSizeMB = 3072;
    extraOptions = ["--loadavg-target=4.0"];
  };
}
