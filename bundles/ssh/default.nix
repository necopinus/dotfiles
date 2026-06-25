{
  pkgs,
  config,
  ...
}: {
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

  # Fix broken SSH Agent sockets on reconnected Tmux sessions
  #
  home.packages = with pkgs;
    lib.optionals (pkgs.stdenv.isLinux && (("${config.home.username}" == "exedev") || ("${config.home.username}" == "necopinus"))) [
      ssh-agent-switcher
    ];

  xdg.configFile."bash/rc.d/ssh.sh" = {
    enable = config.programs.bash.enable && pkgs.stdenv.isLinux && (("${config.home.username}" == "exedev") || ("${config.home.username}" == "necopinus"));
    text = ''
      ssh-agent-switcher --daemon &> /dev/null || true
      export SSH_AUTH_SOCK="/tmp/ssh-agent.$USER"
    '';
  };
  xdg.configFile."zsh/rc.d/ssh.zsh" = {
    enable = config.programs.zsh.enable && pkgs.stdenv.isLinux && (("${config.home.username}" == "exedev") || ("${config.home.username}" == "necopinus"));
    text = ''
      ssh-agent-switcher --daemon &> /dev/null || true
      export SSH_AUTH_SOCK="/tmp/ssh-agent.$USER"
    '';
  };
  xdg.configFile."fish/rc.d/ssh.fish" = {
    enable = config.programs.fish.enable && pkgs.stdenv.isLinux && (("${config.home.username}" == "exedev") || ("${config.home.username}" == "necopinus"));
    text = ''
      ssh-agent-switcher --daemon &> /dev/null || true
      set -gx SSH_AUTH_SOCK "/tmp/ssh-agent.$USER"
    '';
  };
}
