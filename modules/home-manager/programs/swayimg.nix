{
  config,
  lib,
  ...
}: {
  programs.swayimg = {
    enable = lib.mkDefault config.host.gui;
    # opening one image also loads the rest of its directory, so next and
    # previous page through the folder
    initLua = ''
      swayimg.imagelist.adjacent = true
    '';
  };
}
