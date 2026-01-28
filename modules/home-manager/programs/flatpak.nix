{inputs, ...}: {
  imports = [inputs.nix-flatpak.homeManagerModules.nix-flatpak];

  config.services.flatpak = {
    packages = ["com.github.tchx84.Flatseal"];
    update.auto.enable = true;
  };
}
