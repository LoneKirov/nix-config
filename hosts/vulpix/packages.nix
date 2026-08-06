{pkgs, ...}: {
  config = {
    environment.systemPackages = with pkgs; [
      python314Packages.huggingface-hub
      python314Packages.mlx
      ollama
    ];
  };
}
