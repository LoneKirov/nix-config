{
  config,
  lib,
  ...
}: {
  config = {
    programs.atuin = lib.mkMerge [
      {enable = lib.mkDefault true;}
      (lib.mkIf config.programs.atuin.enable {
        daemon.enable = true;
        settings = {
          enter_accept = true;
          sync.records = true;
          stats.common_subcommands = [
            "apt"
            "cargo"
            "docker"
            "git"
            "go"
            "home-manager"
            "ip"
            "nix"
            "nmcli"
            "npm"
            "pnpm"
            "podman"
            "systemctl"
            "tmux"
          ];
        };
      })
    ];
  };
}
