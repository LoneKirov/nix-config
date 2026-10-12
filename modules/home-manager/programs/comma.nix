{
  inputs,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) system;
in {
  # NixOS installs comma and its completion system-wide, so root has them too
  config = lib.mkIf (!(osConfig.programs.nix-index-database.comma.enable or false)) {
    home.packages = [inputs.nix-index-database.packages.${system}.comma-with-db];
    # fish finds a package's completions through XDG_DATA_DIRS, which
    # home-manager only extends with targets.genericLinux
    programs.fish.completions."," = "source ${inputs.self.packages.${system}.comma-fish-completion}/share/fish/vendor_completions.d/,.fish";
  };
}
