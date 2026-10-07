{
  lib,
  osConfig,
  ...
}: {
  programs.ssh = {
    enable = lib.mkDefault true;
    enableDefaultConfig = false;
    settings = let
      # headless hosts authenticate sudo against the forwarded agent (see
      # modules/nixos/pam.nix); the rest have no use for it
      withRssh = lib.filterAttrs (_: host: host.ssh && ! host.gui) (osConfig.hosts or {});
      settings =
        lib.mapAttrsToList (name: _: {
          "${name}" = {
            forwardAgent = true;
          };
          "${name}.lan" = {
            forwardAgent = true;
          };
        })
        withRssh;
    in
      lib.mkMerge settings;
  };
}
