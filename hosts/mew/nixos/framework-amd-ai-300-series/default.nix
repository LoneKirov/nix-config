{inputs, ...}: {
  imports = [
    inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series
    ./audio.nix
    ./bluetooth.nix
    ./hibernate
  ];
}
