{...}: {
  config = {
    programs = {
      zsh.zplug.plugins = [
        {
          name = "plugins/systemd";
          tags = ["from:oh-my-zsh"];
        }
      ];
    };
  };
}
