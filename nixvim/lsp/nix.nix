{
  lib,
  pkgs,
  ...
}: {
  lsp = {
    servers = {
      nil_ls = {
        enable = true;
        config.settings.nil = {
          formatting.command = ["${lib.getExe pkgs.alejandra}"];
        };
      };
      nixd = {
        enable = true;
        config.settings = {
          formatting.command = ["${lib.getExe pkgs.alejandra}"];
        };
      };
    };
  };
}
