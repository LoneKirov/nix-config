{inputs, ...}: {
  imports = [
    inputs.determinate.nixosModules.default
    inputs.nix-index-database.nixosModules.default
  ];

  config.nix = {
    settings = {
      # Enable flakes
      experimental-features = ["nix-command" "flakes"];
      # Have nix use xdg
      use-xdg-base-directories = true;
      # optimize the store on every build
      auto-optimise-store = true;
    };
  };
}
