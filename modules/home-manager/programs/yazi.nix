{
  lib,
  osConfig,
  pkgs,
  ...
}: let
  dms-shell = osConfig.programs.dms-shell.enable or false;
in {
  programs.yazi = lib.mkMerge [
    {
      enable = lib.mkDefault true;
      package = pkgs.yazi.override {_7zz = pkgs._7zz-rar;};
      plugins = {
        inherit (pkgs.yaziPlugins) toggle-pane recycle-bin starship;
      };
      extraPackages = with pkgs; [
        fd
        ffmpeg
        fzf
        imagemagick
        jq
        poppler
        resvg
        ripgrep
        trash-cli
        starship
        wl-clipboard-rs
        zoxide
      ];
      initLua = ''
        require("recycle-bin"):setup()
        require("starship"):setup()
      '';
      settings = {
        preview = {
          image_filter = "lanczos3";
          image_quality = 90;
          max_width = 4000;
          max_height = 4000;
        };
        opener.set-wallpaper = lib.optionals dms-shell [
          {
            run = "dms ipc call wallpaper set %s1";
            for = "linux";
            desc = "Set as wallpaper";
          }
        ];
        open.prepend_rules = lib.optionals dms-shell [
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
          {
            on = ["R" "b"];
            run = "plugin recycle-bin";
            desc = "Open Recycle Bin menu";
          }
        ];
      };
    }
    (lib.mkIf osConfig.services.gvfs.enable {
      plugins = {
        inherit (pkgs.yaziPlugins) gvfs;
      };
      initLua = ''
        require("gvfs"):setup()
      '';
      keymap = {
        mgr.prepend_keymap = [
          {
            on = ["M" "m"];
            run = "plugin gvfs -- select-then-mount";
            desc = "Select device then mount";
          }
          {
            on = ["M" "R"];
            run = "plugin gvfs -- remount-current-cwd-device";
            desc = "Remount device under cwd";
          }
          {
            on = ["M" "u"];
            run = "plugin gvfs -- select-then-unmount --eject";
            desc = "Select device then eject";
          }

          {
            on = ["M" "U"];
            run = "plugin gvfs -- select-then-unmount --eject --force";
            desc = "Select device then force to eject/unmount";
          }
          {
            on = ["M" "a"];
            run = "plugin gvfs -- add-mount";
            desc = "Add a GVFS mount URI";
          }
          {
            on = ["M" "e"];
            run = "plugin gvfs -- edit-mount";
            desc = "Edit a GVFS mount URI";
          }
          {
            on = ["M" "r"];
            run = "plugin gvfs -- remove-mount";
            desc = "Remove a GVFS mount URI";
          }
          {
            on = ["g" "m"];
            run = "plugin gvfs -- jump-to-device";
            desc = "Select device then jump to its mount point";
          }
          {
            on = ["`" "`"];
            run = "plugin gvfs -- jump-back-prev-cwd";
            desc = "Jump back to the position before jumped to device";
          }
          {
            on = ["M" "t"];
            run = "plugin gvfs -- automount-when-cd";
            desc = "Enable automount when cd to device under cwd";
          }
          {
            on = ["M" "T"];
            run = "plugin gvfs -- automount-when-cd --disabled";
            desc = "Disable automount when cd to device under cwd";
          }
        ];
      };
    })
  ];
}
