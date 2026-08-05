{lib, ...}: {
  config = {
    services = {
      openssh = {
        enable = lib.mkDefault true;
      };
    };
  };
}
