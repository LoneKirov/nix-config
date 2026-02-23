{...}: {
  local.kirov.home-manager = {
    services.flatpak.packages = ["com.valvesoftware.Steam"];
    # https://github.com/junegunn/fzf/issues/4015
    programs.fzf.defaultOptions = ["--walker-skip z:"];
  };
}
