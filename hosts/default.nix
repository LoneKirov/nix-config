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
  # every ssh host's pinned key (keys/<host>.pub) must be the key its sops
  # secrets are encrypted to, so the two can't drift after a reinstall
  perSystem = {pkgs, ...}: {
    checks.host-keys = let
      sshHosts = lib.attrNames (lib.filterAttrs (_: nixos: nixos.config.host.ssh) config.flake.nixosConfigurations);
    in
      pkgs.runCommand "host-keys" {nativeBuildInputs = [pkgs.ssh-to-age];} ''
        check() {
          want=$(sed -n "s/^ *- &$1 \(age1[a-z0-9]*\).*/\1/p" ${../.sops.yaml})
          got=$(ssh-to-age < "$2")
          if [ "$got" != "$want" ]; then
            echo "keys/$1.pub converts to $got, but .sops.yaml has '$want' for $1" >&2
            exit 1
          fi
        }
        ${lib.concatMapStrings (name: "check ${name} ${../keys/${name}.pub}\n") sshHosts}
        touch $out
      '';
  };

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
