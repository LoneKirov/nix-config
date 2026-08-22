{
  lib,
  pkgs,
  ...
}: {
  imports = [./lsp];

  config = {
    nixpkgs.config.allowUnfree = true;

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
        extensions.fzf-native.enable = true;
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
      neogit.enable = true;
      web-devicons.enable = true;
      transparent.enable = true;
      colorful-menu.enable = true;
      which-key.enable = true;
      marks.enable = true;
    };
    extraPlugins = [
      (pkgs.vimUtils.buildVimPlugin {
        name = "jjui";
        src = pkgs.fetchFromGitHub {
          owner = "xdagiz";
          repo = "jjui.nvim";
          rev = "e3ab2c482ed06b358dbd0d631b5579a4ae4c5d9b";
          sha256 = "DcFkJwT4lEOC7cW+mYxewFmhgtOTkVCS0mdbllNGPiA=";
        };
        postPatch = ''
          substituteInPlace lua/jjui.lua \
            --replace-fail 'exec_jjui({ "jjui" })' 'exec_jjui({ "${lib.getExe pkgs.jjui}" })' \
        '';
      })
      (pkgs.vimUtils.buildVimPlugin {
        name = "base46";
        src = pkgs.fetchFromGitHub {
          owner = "AvengeMedia";
          repo = "base46";
          rev = "83522e02c6c3b4ea901c4bffd9e0a5e0371c1fe6";
          sha256 = "kwDMC6rYzJYECmGnwn8JiAbffUq7hAXcUH6gPSkk2uI=";
        };
        nvimRequireCheck = "base46";
      })
    ];
    extraConfigLua = ''
      vim.opt.foldenable = false
      vim.opt.runtimepath:append(vim.fn.stdpath("config"))
      require('base46')
      require('transparent').clear_prefix('NeoTree')
      require('jjui')
      pcall(vim.cmd.colorscheme, 'dms')
    '';
    lsp = {
      inlayHints.enable = true;
    };
    keymaps = [
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
      {
        action = "<cmd>WhichKey<CR>";
        key = "<leader>?";
        mode = "n";
      }
      {
        action = "<cmd>Jjui<CR>";
        key = "<leader>jj";
        mode = "n";
      }
    ];
  };
}
