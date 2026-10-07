{lib, ...}: {
  config.plugins.toggleterm = {
    enable = lib.mkDefault true;
    settings = {
      open_mapping = "[[<c-\\>]]"; # raw Lua in nixvim, hence the [[ ]]
      direction = "float";
      float_opts.border = "curved";
      shade_terminals = false;
      # <c-\> toggles the terminal, so <c-\><c-n> can't reach normal mode
      on_create = ''
        function(term)
          vim.keymap.set('t', '<esc><esc>', [[<C-\><C-n>]], { buffer = term.bufnr, desc = 'Exit terminal mode' })
        end
      '';
    };
  };
}
