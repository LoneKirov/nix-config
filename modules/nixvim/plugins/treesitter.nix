{
  config,
  lib,
  ...
}: {
  config = {
    plugins.treesitter = {
      enable = lib.mkDefault true;
      highlight.enable = true;
      indent.enable = false;
      folding.enable = true;
    };

    # keep treesitter folds open by default
    opts.foldenable = lib.mkIf config.plugins.treesitter.enable false;
  };
}
