{
  config,
  pkgs,
  ...
}: {
  programs.ssh = {
    enable = true;
    package = pkgs.openssh;

    includes = ["hosts/*"];
    enableDefaultConfig = false;
    matchBlocks."*" = {
      host = "* !127.0.0.1 !localhost";
      addKeysToAgent = "yes";
      compression = true;
      forwardAgent = false;
      identityFile = "${config.home.homeDirectory}/.ssh/id_ed25519";
      serverAliveInterval = 15;
      serverAliveCountMax = 4;
    };
  };
}
