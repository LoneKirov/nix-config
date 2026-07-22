{pkgs, ...}: {
  programs.fuse.enable = true;
  environment.systemPackages = with pkgs; [
    sshfs
  ];
}
