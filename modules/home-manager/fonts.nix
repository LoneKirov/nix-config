{pkgs, ...}: {
  home.packages = with pkgs; [
    maple-mono.NormalNL-NF-CN-unhinted
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-color-emoji
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
  ];
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      serif = ["Noto Serif"];
      sansSerif = ["Noto Sans"];
      monospace = ["Maple Mono Normal NL NF CN" "JetBrainsMono NF"];
      emoji = ["Noto Color Emoji"];
    };
  };
}
