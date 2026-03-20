{
  inputs,
  lib,
  ...
}: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = let
      nixosConfigurations = inputs.self.outputs.nixosConfigurations;
      withSsh = lib.filterAttrs (name: value: value.config.services.openssh.enable) nixosConfigurations;
      names = builtins.attrNames withSsh;
      matchBlocks =
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
      lib.mkMerge matchBlocks;
  };
}
