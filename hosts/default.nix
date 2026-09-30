{
  config,
  lib,
  ...
}: let
  hosts = {
    articuno = {
      gui = true;
      ssh = true;
    };
    articuno-wsl.wsl = true;
    mew.gui = true;
    moltres = {};
    slowpoke = {};
  };
in {
  flake.nixosConfigurations = lib.mapAttrs (name: _:
    config.flake.lib.nixosSystem {
      modules = [
        ./${name}
        {
          networking.hostName = name;
          inherit hosts;
          user.passwordSopsFile = ./${name}/password.sops.yaml;
        }
      ];
    })
  hosts;
}
