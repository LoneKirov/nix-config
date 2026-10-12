{lib, ...}: {
  config = {
    programs.atuin = {
      enable = lib.mkDefault true;
      daemon.enable = true;
      settings = {
        enter_accept = true;
        sync.records = true;
        # Stats split commands at `|`, so `cmd |& nom` counts as `& nom` unless
        # `&` is stripped as a prefix. Setting this replaces atuin's default of
        # just `sudo`.
        stats.common_prefix = ["sudo" "&"];
        stats.common_subcommands = [
          ","
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
          "nixos-rebuild"
          "nmcli"
          "npm"
          "pnpm"
          "podman"
          "sops"
          "systemctl"
          "tailscale"
          "tmux"
          "wezterm"
        ];
      };
    };
  };
}
