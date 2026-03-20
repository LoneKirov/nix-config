{
  config,
  lib,
  ...
}: {
  config = {
    programs.zsh = {
      enable = true;
      history.path = "${config.xdg.stateHome}/zsh/zsh_history";
      initContent = ''
        # [Ctrl-RightArrow] - move forward one word
        bindkey '^[[1;5C' forward-word
        # [Ctrl-LeftArrow] - move backward one word
        bindkey '^[[1;5D' backward-word
      '';
      antidote = {
        enable = true;
        useFriendlyNames = true;
        plugins = lib.mkBefore [
          "getantidote/use-omz"
          "marlonrichert/zsh-autocomplete"
          "zsh-users/zsh-autosuggestions"
          "zsh-users/zsh-syntax-highlighting"
          "ohmyzsh/ohmyzsh path:plugins/sudo"
          "ohmyzsh/ohmyzsh path:plugins/colored-man-pages"
          "ohmyzsh/ohmyzsh path:plugins/systemd"
        ];
      };
      enableCompletion = false;
      shellAliases = {
        wget = "wget --no-hsts";
      };
    };
  };
}
