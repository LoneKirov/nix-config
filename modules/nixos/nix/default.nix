{inputs, ...}: {
  imports = [
    inputs.determinate.nixosModules.default
    inputs.nix-index-database.nixosModules.default
    ./nixremote.nix
  ];

  config = {
    nix = {
      settings = {
        # Enable flakes
        experimental-features = ["nix-command" "flakes"];
        # Have nix use xdg
        use-xdg-base-directories = true;
        # optimize the store on every build
        auto-optimise-store = true;
      };
    };
    system.autoUpgrade = {
      flake = "github:LoneKirov/nix-config";
      dates = "daily";
      allowReboot = true;
      randomizedDelaySec = "45min";
      runGarbageCollection = true;
    };
  };
}
