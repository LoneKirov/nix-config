{
  config,
  inputs,
  lib,
  pkgs,
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
        enable = lib.mkDefault config.programs.jujutsu.enable;
        package = lib.mkDefault inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.jj-gh;
        aliases = {
          pr = "pr";
        };
        settings = {
          auto_merge = true;
          auto_merge_method = "squash";
          nerdfonts = true;
        };
      };
    };
  };
}
