{lib, ...}: {
  config = {
    programs.pay-respects = {
      enable = lib.mkDefault true;
      options = [
        "--alias"
        "fuck"
      ];
    };
  };
}
