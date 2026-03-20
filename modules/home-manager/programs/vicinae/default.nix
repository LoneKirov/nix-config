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
  defaultBaseSettings = options.local.programs.vicinae.baseSettings.default;
  baseSettings = config.local.programs.vicinae.baseSettings;
  mergedBaseSettings = lib.recursiveUpdate defaultBaseSettings baseSettings;
  jsonFormat = pkgs.formats.json {};
in {
  options.local.programs.vicinae.baseSettings = lib.mkOption {
    inherit (jsonFormat) type;
    default = {
      font.normal.family = "Maple Mono Normal NL NF CN";
      theme.dark = {
        name = "matugen";
        icon_theme = config.gtk.iconTheme.name;
      };
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
        "@tonka3000/store.raycast.homeassistant".preferences.instance = "https://homeassistant.kanto.casa/";
        "@jomifepe/store.raycast.bitwarden".preferences.cliPath = lib.getExe pkgs.bitwarden-cli;
      };
    };
    description = ''
      home-manager managed settings imported in {file}`~/.config/vicinae/settings.json`
    '';
  };

  config = lib.mkMerge [
    {programs.vicinae.enable = lib.mkDefault config.programs.niri.enable;}
    (lib.mkIf config.programs.vicinae.enable {
      local.programs.matugen.config.templates.vicinae = {
        input_path = ./vicinae.theme.toml;
        output_path = "${dataHome}/vicinae/themes/matugen.toml";
        post_hook = "${lib.getExe pkgs.vicinae} theme set matugen";
      };
      programs.vicinae.systemd.enable = true;
      xdg.configFile = {
        "vicinae/settings.json".source = mkOutOfStoreSymlink vicinaeSettings;
        "vicinae/base-settings.json".source = jsonFormat.generate "vicinae-base" mergedBaseSettings;
      };
      home.packages = [pkgs.qalculate-gtk];
    })
  ];
}
