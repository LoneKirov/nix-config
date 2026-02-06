{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    git
    lnav
    vim
  ];
}
