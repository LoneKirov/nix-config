_: {
  services.tailscale = {
    useRoutingFeatures = "server";
    openFirewall = true;
  };
  # tailnet access is governed by Tailscale ACLs
  networking.firewall.trustedInterfaces = ["tailscale0"];
}
