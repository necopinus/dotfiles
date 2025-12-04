{pkgs, ...}: {
  programs.ssh = {
    enable = true;
    package = pkgs.openssh;

    includes = ["hosts/*"];
    enableDefaultConfig = false;
    extraConfig = "Match host * exec \"${pkgs.gnupg}/bin/gpg-connect-agent UPDATESTARTUPTTY /bye\"";
    matchBlocks."*" = {
      host = "* !127.0.0.1 !localhost";
      addKeysToAgent = "yes";
      compression = true;
      forwardAgent = false;
      serverAliveInterval = 15;
      serverAliveCountMax = 4;
    };
  };
}
