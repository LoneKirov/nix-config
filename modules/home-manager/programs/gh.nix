{
  config,
  inputs,
  lib,
  ...
}: {
  imports = [inputs.jj-gh.homeManagerModules.default];

  config = {
    programs = {
      gh = {
        enable = lib.mkDefault true;
        settings.git_protocol = "ssh";
      };
      jujutsu.gh = lib.mkIf config.programs.gh.enable {
        enable = config.programs.jujutsu.enable;
        aliases = {
          pr = "pr";
        };
        settings.nerdfonts = true;
      };
    };
  };
}
