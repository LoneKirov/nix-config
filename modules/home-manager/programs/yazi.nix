{pkgs, ...}: {
  programs.yazi = {
    enable = true;
    package = pkgs.yazi.override {_7zz = pkgs._7zz-rar;};
    plugins = {
      inherit (pkgs.yaziPlugins) toggle-pane recycle-bin starship;
    };
    extraPackages = with pkgs; [
      ffmpeg
      jq
      poppler
      fd
      ripgrep
      fzf
      zoxide
      resvg
      wl-clipboard-rs
      imagemagick
      trash-cli
      starship
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
  };
}
