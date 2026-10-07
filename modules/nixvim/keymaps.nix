{lib, ...}: {
  config = {
    globals.mapleader = lib.mkDefault " ";

    keymaps = [
      {
        action = "<cmd>nohlsearch<CR>";
        key = "<Esc>";
        mode = "n";
        options.desc = "Clear search highlight";
      }
    ];
  };
}
