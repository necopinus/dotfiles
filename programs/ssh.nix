{pkgs, ...}: {
  programs.ssh = {
    enable = true;
    package = pkgs.openssh;

    includes = ["hosts/*"];
    enableDefaultConfig = false;
    matchBlocks = {
      "set-gpg-tty" = {
        match = ''
          host * exec "gpg-connect-agent UPDATESTARTUPTTY /bye"
        '';
      };
      "*" = {
        host = "* !127.0.0.1 !localhost";
        addKeysToAgent = "yes";
        compression = true;
        forwardAgent = false;
        serverAliveInterval = 15;
        serverAliveCountMax = 4;
      };
    };
  };
}
