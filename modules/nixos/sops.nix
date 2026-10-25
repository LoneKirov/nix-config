{inputs, ...}: {
  imports = [inputs.sops-nix.nixosModules.sops];

  # sops-nix decrypts with the ed25519 key in services.openssh.hostKeys, but only
  # looks there when sshd is enabled or host keys are generated without it
  services.openssh.generateHostKeys = true;
}
