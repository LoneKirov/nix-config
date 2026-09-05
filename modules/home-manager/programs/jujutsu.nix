{
  config,
  lib,
  pkgs,
  ...
}: {
  config = let
    inherit (config.programs.jujutsu) enable;
    jj-with-watchman = pkgs.symlinkJoin {
      name = "jujutsu-with-watchman";
      paths = [pkgs.jujutsu];
      nativeBuildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram $out/bin/jj \
          --prefix PATH : ${lib.makeBinPath [pkgs.watchman]}
      '';
    };
  in {
    programs = {
      jujutsu = {
        enable = lib.mkDefault config.programs.git.enable;
        package = jj-with-watchman;
        settings = {
          user = config.programs.git.settings.user;
          fsmonitor = {
            backend = "watchman";
            watchman.register-snapshot-trigger = true;
          };
        };
      };
      jjui.enable = enable;
      zsh.antidote.plugins = lib.mkIf enable [
        "ohmyzsh/ohmyzsh path:plugins/jj"
      ];
    };
  };
}
