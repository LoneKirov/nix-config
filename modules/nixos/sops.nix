{
  config,
  inputs,
  lib,
  ...
}: {
  imports = [inputs.sops-nix.nixosModules.sops];

  # hosts without sshd still need a host key, since sops decrypts with it
  services.openssh.generateHostKeys = true;

  sops.age = {
    # age reads the ssh key as it is, so .sops.yaml lists each host's ssh public
    # key as its recipient
    sshKeyFile =
      lib.mkDefault
      (lib.findFirst (key: key.type == "ed25519")
        (throw "sops needs an ed25519 key in services.openssh.hostKeys")
        config.services.openssh.hostKeys).path;
    # defaults to the same key converted with ssh-to-age, which
    # sops-install-secrets skips once sshKeyFile is set
    sshKeyPaths = lib.mkDefault [];
  };
}
