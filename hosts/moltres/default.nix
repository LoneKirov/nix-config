{
  internal-lib,
  withSystem,
  ...
}:
withSystem "x86_64-linux" (
  {pkgs, ...}:
    internal-lib.mkHomeManagerConfiguration {
      pkgs = pkgs.extend (import ./overlays);
      modules = [
        {home.stateVersion = "25.05";}
        ./home-manager
      ];
    }
)
