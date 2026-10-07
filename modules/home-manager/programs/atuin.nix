{lib, ...}: {
  config = {
    programs.atuin = {
      enable = lib.mkDefault true;
      daemon.enable = true;
      settings = {
        enter_accept = true;
        sync.records = true;
        stats.common_subcommands = [
          "apt"
          "cargo"
          "devenv"
          "dms"
          "docker"
          "git"
          "go"
          "home-manager"
          "ip"
          "jj"
          "nh"
          "niri"
          "nix"
          "nmcli"
          "npm"
          "pnpm"
          "podman"
          "systemctl"
          "tmux"
          "wezterm"
        ];
      };
    };
  };
}
