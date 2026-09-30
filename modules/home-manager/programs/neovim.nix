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
      vimdiffAlias = true;
      nixpkgs.source = inputs.nixpkgs;
    };
    home.sessionVariables = lib.mkIf enable {
      MANPAGER = "${lib.getExe build.package} -c 'Man!'";
    };
  };
}
