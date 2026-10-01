{
  config,
  inputs,
  lib,
  ...
}: {
  imports = [inputs.nixvim.homeModules.nixvim];

  config = let
    inherit (config.programs.nixvim) enable build;
  in {
    programs.nixvim = {
      enable = lib.mkDefault true;
      defaultEditor = true;
      imports = [../../nixvim];
      # nixvim's home-manager wrapper doesn't take specialArgs
      _module.args = {inherit inputs;};
      vimdiffAlias = true;
    };
    home.sessionVariables = lib.mkIf enable {
      MANPAGER = "${lib.getExe build.package} -c 'Man!'";
    };
  };
}
