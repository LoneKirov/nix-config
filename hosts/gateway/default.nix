{internal-lib, ...}: {
  perSystem = {pkgs, ...}: {
    legacyPackages.homeConfigurations."kirov@gateway" = internal-lib.mkHomeManagerConfiguration {
      inherit pkgs;
      modules = [
        {home.stateVersion = "25.05";}
      ];
    };
  };
}
