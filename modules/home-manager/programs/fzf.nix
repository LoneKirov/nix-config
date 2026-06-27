{
  lib,
  pkgs,
  ...
}: {
  config = {
    programs = {
      fzf = {
        enable = lib.mkDefault true;
        # use fzf plugin instead
        enableFishIntegration = false;
      };
      fish.plugins = [
        {
          name = "fzf";
          src = pkgs.fetchFromGitHub {
            owner = "PatrickF1";
            repo = "fzf.fish";
            rev = "6a6136998879dcc1f29a405dfdd6b92c5f229c39";
            sha256 = "ql8UncXGwOIpyC49w1bCRfynRB02u7s1a1rOWTfKcTk=";
          };
        }
      ];
    };
  };
}
