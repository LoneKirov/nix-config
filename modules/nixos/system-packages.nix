{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    git
    pv
    neovim
  ];
}
