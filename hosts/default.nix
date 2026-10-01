{
  config,
  lib,
  ...
}: let
  hosts = {
    articuno = {
      gui = true;
      ssh = true;
      backup.targets = ["moltres"];
    };
    articuno-wsl.wsl = true;
    mew = {
      gui = true;
      backup.targets = ["moltres"];
    };
    moltres.backup.receive = "/srv/backup";
    slowpoke.backup.targets = ["moltres"];
  };
in {
  flake.nixosConfigurations = lib.mapAttrs (name: _:
    config.flake.lib.nixosSystem {
      modules = [
        ./${name}
        ({config, ...}: {
          networking.hostName = name;
          inherit hosts;
          user.passwordSopsFile = ./${name}/password.sops.yaml;
          btrbk.sshKeySopsFile = lib.mkIf (config.host.backup.targets != []) ./${name}/btrbk.sops.yaml;
        })
      ];
    })
  hosts;
}
