{
  config,
  lib,
  pkgs,
  options,
  ...
}: let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  inherit (config.xdg) configHome dataHome;
  vicinaeSettings = "${configHome}/nix-config/modules/home-manager/programs/vicinae/settings.json";
  defaultBaseSettings = options.programs.vicinae.baseSettings.default;
  baseSettings = config.programs.vicinae.baseSettings;
  mergedBaseSettings = lib.recursiveUpdate defaultBaseSettings baseSettings;
  jsonFormat = pkgs.formats.json {};
in {
  options.programs.vicinae.baseSettings = lib.mkOption {
    inherit (jsonFormat) type;
    default = {
      font.normal.family = "FiraCode Nerd Font";
      theme.dark.name = "matugen";
      providers = {
        applications.entrypoints = {
          btop.enabled = false;
          cups.enabled = false;
          gvim.enabled = false;
          khal.enabled = false;
          nvim.enabled = false;
          xterm.enabled = false;
          yazi.enabled = false;
        };
        clipboard.preferences.eraseOnStartup = true;
      };
    };
    description = ''
      home-manager managed settings imported in {file}`~/.config/vicinae/settings.json`
    '';
  };

  config = lib.mkMerge [
    {programs.vicinae.enable = lib.mkDefault config.programs.niri.enable;}
    (lib.mkIf config.programs.vicinae.enable {
      programs = {
        vicinae = {
          systemd.enable = true;
        };
        matugen.config.templates.vicinae = {
          input_path = ./vicinae.toml;
          output_path = "${dataHome}/vicinae/themes/matugen.toml";
          post_hook = "vicinae theme set matugen";
        };
      };
      xdg.configFile = {
        "vicinae/settings.json".source = mkOutOfStoreSymlink vicinaeSettings;
        "vicinae/base-settings.json".source = jsonFormat.generate "vicinae-base" mergedBaseSettings;
      };
      home.packages = [pkgs.qalculate-gtk];
    })
  ];
}
