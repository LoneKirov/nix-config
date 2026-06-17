{
  lib,
  pkgs,
  ...
}: {
  lsp = {
    servers = {
      nixd = {
        enable = true;
        config.settings.nixd = let
          flake = ''(builtins.getFlake (builtins.toString ./.))'';
        in {
          nixpkgs.expr = "import ${flake}.inputs.nixpkgs {}";

          formatting.command = ["${lib.getExe pkgs.alejandra}"];

          options = {
            nixos.expr = ''
              let
                hostname = builtins.replaceStrings ["\n"] [""] (builtins.readFile "/etc/hostname");
              in
                ${flake}.nixosConfigurations.''${hostname}.options
            '';
            home-manager.expr = ''
              let
                hostname = builtins.replaceStrings ["\n"] [""] (builtins.readFile "/etc/hostname");
              in
                ${flake}.nixosConfigurations.''${hostname}.options.home-manager.users.type.getSubOptions []
            '';
          };
        };
      };
    };
  };
}
