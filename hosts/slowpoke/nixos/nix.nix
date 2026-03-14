{config, ...}: {
  nix = {
    buildMachines = [
      {
        hostName = "moltres";
        systems = ["x86_64-linux" "aarch64-linux"];
        protocol = "ssh-ng";
        sshUser = "nixremote";
        sshKey = config.sops.secrets.nixremote_ssh_key.path;
        maxJobs = 1;
        speedFactor = 2;
        supportedFeatures = ["nixos-test" "benchmark" "big-parallel" "kvm"];
        mandatoryFeatures = [];
      }
    ];
    distributedBuilds = true;
    settings.max-jobs = 0;
  };
  systemd.tmpfiles.rules = [
    "f /root/.ssh/config 0700 root root - StrictHostKeyChecking=accept-new"
  ];
}
