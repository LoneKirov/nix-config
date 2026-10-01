{
  config,
  lib,
  ...
}: let
  inherit (config.plugins) blink-cmp colorful-menu;
in {
  config.plugins = {
    blink-cmp = {
      enable = lib.mkDefault true;
      settings = {
        appearance = {
          nerd_font_variant = "mono";
          use_nvim_cmp_as_default = true;
        };
        keymap.preset = "super-tab";
        fuzzy.implementation = "prefer_rust_with_warning";
        completion = {
          ghost_text.enabled = true;
          documentation = {
            auto_show = true;
            auto_show_delay_ms = 500;
          };
          trigger.show_in_snippet = false;
          menu.draw = lib.mkIf colorful-menu.enable (lib.nixvim.mkRaw ''
            {
                treesitter = { 'lsp' },
                -- We don't need label_description now because label and label_description are already
                -- combined together in label by colorful-menu.nvim.
                columns = { { "kind_icon" }, { "label", gap = 1 } },
                components = {
                    label = {
                        text = function(ctx)
                            return require("colorful-menu").blink_components_text(ctx)
                        end,
                        highlight = function(ctx)
                            return require("colorful-menu").blink_components_highlight(ctx)
                        end,
                    },
                },
            }
          '');
        };
      };
    };
    colorful-menu.enable = lib.mkDefault blink-cmp.enable;
  };
}
