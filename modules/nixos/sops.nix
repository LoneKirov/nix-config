{inputs, ...}: {
  imports = [inputs.sops-nix.nixosModules.sops];

  config.sops = {
    defaultSopsFile = ../../secrets/default.yaml;
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
  };
}
