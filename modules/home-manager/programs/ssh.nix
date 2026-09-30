{
  lib,
  osConfig,
  ...
}: {
  programs.ssh = {
    enable = lib.mkDefault true;
    enableDefaultConfig = false;
    settings = let
      withSsh = lib.filterAttrs (_: host: host.ssh) (osConfig.hosts or {});
      settings =
        lib.mapAttrsToList (name: _: {
          "${name}" = {
            forwardAgent = true;
          };
          "${name}.lan" = {
            forwardAgent = true;
          };
        })
        withSsh;
    in
      lib.mkMerge settings;
  };
}
