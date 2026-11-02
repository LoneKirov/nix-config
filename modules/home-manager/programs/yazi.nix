{
  lib,
  osConfig,
  pkgs,
  ...
}: let
  dux-shell = osConfig.programs.dux-shell.enable or false;
in {
  programs.yazi = lib.mkMerge [
    {
      enable = lib.mkDefault true;
      package = pkgs.yazi.override {_7zz = pkgs._7zz-rar;};
      plugins = {
        inherit (pkgs.yaziPlugins) toggle-pane starship;
      };
      extraPackages = with pkgs;
        [
          fd
          ffmpeg
          fzf
          imagemagick
          jq
          poppler
          resvg
          ripgrep
          starship
          zoxide
        ]
        ++ lib.optionals dux-shell [
          wl-clipboard-rs
        ];
      initLua = ''
        require("starship"):setup()
      '';
      settings = {
        preview = {
          image_filter = "lanczos3";
          image_quality = 90;
          max_width = 4000;
          max_height = 4000;
        };
        opener.set-wallpaper = lib.optionals dux-shell [
          {
            run = "dms ipc call wallpaper set %s1";
            for = "linux";
            desc = "Set as wallpaper";
          }
        ];
        open.prepend_rules = lib.optionals dux-shell [
          {
            mime = "image/*";
            use = ["open" "reveal" "set-wallpaper"];
          }
        ];
      };
      keymap = {
        mgr.prepend_keymap = [
          {
            on = "T";
            run = "plugin toggle-pane max-preview";
            desc = "Maximize or restore the preview pane";
          }
        ];
      };
    }
  ];
}
