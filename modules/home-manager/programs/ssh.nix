{
  inputs,
  lib,
  ...
}: {
  programs.ssh = {
    enable = lib.mkDefault true;
    enableDefaultConfig = false;
    settings = let
      nixosConfigurations = inputs.self.outputs.nixosConfigurations;
      withSsh = lib.filterAttrs (_: value: value.config.services.openssh.enable) nixosConfigurations;
      names = builtins.attrNames withSsh;
      settings =
        map (host: {
          "${host}" = {
            forwardAgent = true;
          };
          "${host}.lan" = {
            forwardAgent = true;
          };
        })
        names;
    in
      lib.mkMerge settings;
  };
}
