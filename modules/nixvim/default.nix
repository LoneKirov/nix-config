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
      blink-cmp = {
        enable = true;
        settings.keymap.preset = "super-tab";
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
    };
    colorschemes.base16.enable = true;
    extraConfigLua = lib.optionalString hmConfig.programs.dms-shell.enable ''
      -- dankcolors is a lazy.nvim plugin but lazy doesn't play nice
      -- with nixvim managed plugins so we just load the plugin manually
      require('plugins/dankcolors')[1].config()
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
