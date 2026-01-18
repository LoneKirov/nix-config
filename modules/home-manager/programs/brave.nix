{
  osConfig,
  lib,
  ...
}: let
  osConfig' = lib.attrsets.optionalAttrs (!isNull osConfig) osConfig;
  xserverEnabled = lib.attrsets.attrByPath ["services" "xserver" "enable"] false osConfig';
in {
  config.programs.brave = {
    enable = lib.mkDefault xserverEnabled;
    extensions = [];
    commandLineArgs = [];
  };
}
