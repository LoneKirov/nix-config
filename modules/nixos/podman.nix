{inputs, ...}: {
  imports = [inputs.quadlet-nix.nixosModules.quadlet];

  config.virtualisation.quadlet.enable = true;
}
