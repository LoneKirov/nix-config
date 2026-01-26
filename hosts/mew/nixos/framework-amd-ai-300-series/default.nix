{inputs, ...}: {
  imports = [
    inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series
    ./bluetooth.nix
    ./fingerprint.nix
    ./hibernate
  ];
}
