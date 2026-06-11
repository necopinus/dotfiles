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
    settings."*" = {
      AddKeysToAgent = "yes";
      Compression = true;
      ForwardAgent = false;
      IdentityFile = "${config.home.homeDirectory}/.ssh/id_ed25519";
      ServerAliveInterval = 15;
      ServerAliveCountMax = 4;
    };
  };
}
