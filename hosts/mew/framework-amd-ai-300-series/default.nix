{inputs, ...}: {
  imports = [
    inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series
    ./charge-limit.nix
    ./fingerprint
    ./hibernate
  ];
}
