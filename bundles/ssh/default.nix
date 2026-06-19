{...}: {
  programs.ssh = {
    enable = true;

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
