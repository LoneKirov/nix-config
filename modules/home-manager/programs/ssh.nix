{
  inputs,
  lib,
  ...
}: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = let
      nixosConfigurations = inputs.self.outputs.nixosConfigurations;
      withSsh = lib.filterAttrs (name: value: value.config.services.openssh.enable) nixosConfigurations;
      names = builtins.attrNames withSsh;
      settings =
        map (host: {
          "${host}" = {
            inherit host;
            forwardAgent = true;
          };
          "${host}.lan" = {
            inherit host;
            forwardAgent = true;
          };
        })
        names;
    in
      lib.mkMerge settings;
  };
}
