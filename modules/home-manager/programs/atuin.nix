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
          "dms"
          "docker"
          "git"
          "go"
          "home-manager"
          "ip"
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
