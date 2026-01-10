{
  hostname,
  username,
  ...
}: {
  networking = {
    networkmanager.enable = true;
    hostName = hostname;
  };
  services.tailscale = {
    enable = true;
    extraSetFlags = ["--operator=${username}"];
  };
}
