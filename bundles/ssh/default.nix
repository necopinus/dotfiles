{pkgs, ...}: {
  programs.ssh = {
    enable = true;
    package = pkgs.openssh;

    includes = ["hosts/*"];
    enableDefaultConfig = false;
    settings."*" = {
      AddKeysToAgent = "yes";
      Compression = true;
      ForwardAgent = false;
      ServerAliveInterval = 15;
      ServerAliveCountMax = 4;
    };
  };
}
