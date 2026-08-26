{
  lib,
  pkgs,
  ...
}: {
  home = {
    packages = with pkgs; [
      maple-mono.NF-CN-unhinted
      nerd-fonts.jetbrains-mono
      noto-fonts
      noto-fonts-color-emoji
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
    ];
    sessionVariables = {
      # https://github.com/ryanoasis/nerd-fonts/wiki/FAQ-and-Troubleshooting#less-settings
      LESSUTFCHARDEF = "E000-F8FF:p,F0000-FFFFD:p,100000-10FFFD:p";
    };
  };
  fonts.fontconfig = {
    enable = lib.mkDefault true;
    defaultFonts = {
      serif = ["Noto Serif"];
      sansSerif = ["Noto Sans"];
      monospace = ["Maple Mono NF CN" "JetBrainsMono NF"];
      emoji = ["Noto Color Emoji"];
    };
  };
}
