{
  hmConfig,
  lib,
  ...
}: let
  yazi = hmConfig.programs.yazi.enable;
  git = hmConfig.programs.git.enable;
  fzf = hmConfig.programs.fzf.enable;
in {
  imports = [./lsp];

  config = {
    viAlias = true;
    vimAlias = true;
    plugins = {
      lspconfig.enable = true;
      lsp-format.enable = true;
      treesitter = {
        enable = true;
        highlight.enable = true;
        indent.enable = false;
        folding.enable = true;
      };
      blink-cmp = {
        enable = true;
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
            menu.draw = lib.nixvim.mkRaw ''
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
              },
            '';
          };
        };
      };
      telescope = {
        enable = true;
        extensions.fzf-native.enable = fzf;
      };
      neo-tree = {
        enable = true;
        settings = {
          close_if_last_window = true;
          filesystem = {
            use_libuv_file_watcher = true;
            follow_current_file = {
              enabled = true;
              leave_dirs_open = true;
            };
          };
        };
      };
      diffview.enable = true;
      neogit.enable = git;
      web-devicons.enable = true;
      yazi.enable = yazi;
      transparent.enable = true;
      colorful-menu.enable = true;
    };
    colorschemes.base16.enable = true;
    extraConfigLua = ''
      vim.opt.foldenable = false
      ${lib.optionalString hmConfig.programs.dms-shell.enable ''
        -- dankcolors is a lazy.nvim plugin but lazy doesn't play nice
        -- with nixvim managed plugins so we just load the plugin manually
        require('plugins/dankcolors')[1].config()
      ''}
      require('transparent').clear_prefix('NeoTree')
    '';
    lsp = {
      inlayHints.enable = true;
    };
    keymaps =
      [
        {
          action = "<cmd>Neotree filesystem<CR>";
          key = "<leader>ntf";
          mode = "n";
        }

        {
          action = "<cmd>Telescope find_files<CR>";
          key = "<leader>tff";
          mode = "n";
        }

        {
          action = "<cmd>Telescope grep_string<CR>";
          key = "<leader>tg";
          mode = "n";
        }
        {
          action = "<cmd>Telescope live_grep<CR>";
          key = "<leader>tlg";
          mode = "n";
        }
        {
          action = "<cmd>Telescope buffers<CR>";
          key = "<leader>tb";
          mode = "n";
        }
        {
          action = "<cmd>Telescope current_buffer_fuzzy_find<CR>";
          key = "<leader>tbff";
          mode = "n";
        }
      ]
      ++ lib.optionals git [
        {
          action = "<cmd>Telescope git_files<CR>";
          key = "<leader>tgf";
          mode = "n";
        }
        {
          action = "<cmd>Telescope git_commits<CR>";
          key = "<leader>tgc";
          mode = "n";
        }
        {
          action = "<cmd>Telescope git_status<CR>";
          key = "<leader>tgs";
          mode = "n";
        }
        {
          action = "<cmd>Neogit<CR>";
          key = "<leader>gg";
          mode = "n";
        }
      ]
      ++ lib.optionals yazi [
        {
          action = "<cmd>Yazi<CR>";
          key = "<leader>yy";
          mode = "n";
        }
      ];
  };
}
