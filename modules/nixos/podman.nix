{inputs, ...}: {
  imports = [inputs.quadlet-nix.nixosModules.quadlet];

  config = {
    virtualisation.quadlet = {
      enable = true;
      autoUpdate.enable = true;
    };

    users.users.containers = {
      isSystemUser = true;
      autoSubUidGidRange = true;
      description = "User required by podman to get subuids from.";
      group = "containers";
    };
    users.groups.containers = {};
  };
}
