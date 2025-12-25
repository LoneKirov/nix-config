{
  config,
  lib,
  pkgs,
  ...
}: {
  config = {
    programs.nixvim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      plugins = {
        lspconfig.enable = true;
        lsp-format.enable = true;
        blink-cmp = {
          enable = true;
          settings.keymap.preset = "super-tab";
        };
        telescope.enable = true;
        neo-tree.enable = true;
        web-devicons.enable = true;
      };
      lsp = {
        inlayHints.enable = true;

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
    };
  };
}
