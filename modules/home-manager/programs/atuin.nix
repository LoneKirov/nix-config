{lib, ...}: {
  config = {
    programs.atuin = {
      enable = lib.mkDefault true;
      daemon.enable = true;
      settings = {
        enter_accept = true;
        sync.records = true;
        # Records coding agents' sessions for `atuin threads` and `atuin resume`
        # through the daemon above. The daemon reads this only when it starts,
        # and home-manager's systemd unit doesn't restart it on a config change.
        threads.capture = lib.mkDefault true;
        # atuin's secrets_filter only knows specific token formats, so it lets
        # through keys passed as a plain flag value
        history_filter = ["--api-key[= ]"];
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
