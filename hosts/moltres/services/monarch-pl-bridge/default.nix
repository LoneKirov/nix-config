{
  config,
  pkgs,
  ...
}: let
  bridgeSrc = pkgs.fetchFromGitHub {
    owner = "Treygec";
    repo = "Monarch-ProjectionLab-Bridge";
    rev = "27e7fe9e342e68fc922dedb4efdc65c5469153c3";
    sha256 = "sha256-vP73Kix5ML9hbSCuUh/0bLRbWU6421ZNYbUMzpgNPQs=";
  };
in {
  virtualisation.quadlet = {
    networks.monarch-pl-bridge = {
      unitConfig = {
        Description = "Network for Monarch-ProjectionLab-Bridge";
        Wants = ["network-online.target"];
        After = ["network-online.target"];
      };
      networkConfig = {
        ipv6 = true;
        options = {
          isolate = "strict";
        };
      };
      autoStart = true;
    };

    builds."monarch-pl-bridge" = {
      unitConfig = {
        Description = "Image build for Monarch-ProjectionLab-Bridge";
      };
      buildConfig = {
        file = "${bridgeSrc}/Monarch API/Dockerfile";
      };
    };

    containers."monarch-pl-bridge" = {
      unitConfig = {
        Description = "Monarch-ProjectionLab-Bridge service";
      };
      containerConfig = {
        image = config.virtualisation.quadlet.builds."monarch-pl-bridge".ref;
        networks = [config.virtualisation.quadlet.networks.monarch-pl-bridge.ref];
        userns = "auto";
      };
    };
  };

  local.services.caddy.virtualHosts."monarch-pl-bridge.kanto.casa" = ''
    reverse_proxy monarch-pl-bridge:47821
  '';
}
