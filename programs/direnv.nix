{
  config,
  pkgs,
  ...
}: {
  programs.direnv = {
    enable = true;
    nix-direnv = {
      enable = true;

      # Replace `>/dev/stderr` with `1>&2` in nix-direnv to fix access
      # errors on Debian (the weird permission dance and usage of $out
      # is because running sed on share/nix-direnv/direnvrc doesn't
      # result in any changes, even if the old installPhase is placed
      # last)
      #
      package = pkgs.nix-direnv.overrideAttrs (previousAttrs: {
        buildInputs = previousAttrs.buildInputs ++ [pkgs.gnused];
        installPhase = ''
          ${previousAttrs.installPhase}
          chmod 644 $out/share/nix-direnv/direnvrc
          chmod 755 $out/share/nix-direnv
          sed -i "s#>/dev/stderr#1>\&2#g" $out/share/nix-direnv/direnvrc
          chmod 444 $out/share/nix-direnv/direnvrc
          chmod 555 $out/share/nix-direnv
        '';
      });
    };
    config = {
      whitelist = {
        prefix = ["${config.home.homeDirectory}/engagements"];
      };
    };
  };
}
