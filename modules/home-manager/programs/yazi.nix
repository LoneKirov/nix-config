{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  dux-shell = osConfig.programs.dux-shell.enable or false;
  swayimg = config.programs.swayimg.enable;
  wezterm = config.programs.wezterm.enable;
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
        opener = {
          # yazi's previewer shows only a GIF's first frame
          # (https://github.com/sxyazi/yazi/issues/51), while wezterm
          # animates the GIFs that imgcat sends it
          imgcat = lib.optionals wezterm [
            {
              run = "clear; wezterm imgcat --hold %s1";
              block = true;
              for = "linux";
              desc = "Show in terminal";
            }
          ];
          swayimg = lib.optionals swayimg [
            {
              run = "swayimg %s";
              orphan = true;
              for = "linux";
              desc = "swayimg";
            }
          ];
          set-wallpaper = lib.optionals dux-shell [
            {
              run = "dms ipc call wallpaper set %s1";
              for = "linux";
              desc = "Set as wallpaper";
            }
          ];
        };
        open.prepend_rules =
          [
            {
              mime = "image/*";
              # swayimg needs a Wayland session, so imgcat stays as the
              # fallback for yazi run over ssh on a gui host
              use =
                lib.optionals swayimg ["swayimg"]
                ++ lib.optionals wezterm ["imgcat"]
                ++ ["open" "reveal"]
                ++ lib.optionals dux-shell ["set-wallpaper"];
            }
          ]
          ++ lib.optionals swayimg [
            {
              mime = "folder/*";
              # yazi's default folder openers; edit stays first because
              # <Enter> on a folder runs the first one
              use = ["edit" "swayimg" "open" "reveal"];
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
          {
            on = ["F" "f"];
            run = "search_do --via=fd --args='--type=f'";
            desc = "List all files recursively";
          }
          {
            on = ["F" "a"];
            run = "search_do --via=fd --args='--type=f --no-ignore'";
            desc = "List all files recursively, including ignored ones";
          }
        ];
      };
    }
  ];
}
