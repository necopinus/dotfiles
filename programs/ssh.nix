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

  # Start ssh-agent, if necessary
  #
  #   https://stackoverflow.com/questions/18880024/start-ssh-agent-on-login/18915067#18915067
  #
  xdg.configFile."bash/rc.d/ssh.sh" = {
    enable = config.programs.bash.enable;
    text = ''
      if [[ -z "$SSH_AUTH_SOCK" ]]; then
        if [[ -f "$HOME"/.ssh/agent.env ]]; then
          source "$HOME"/.ssh/agent.env
        fi
        if [[ -z "$SSH_AGENT_PID" ]] || [[ $(ps -ef | grep -v grep | grep -c "$SSH_AGENT_PID") -eq 0 ]]; then
          if [[ ! -d "$HOME"/.ssh ]]; then
            mkdir -p "$HOME"/.ssh
          fi
          ssh-agent | sed '/^echo/d' > "$HOME"/.ssh/agent.env
          source "$HOME"/.ssh/agent.env
        fi
      fi
    '';
  };
  xdg.configFile."zsh/rc.d/ssh.sh" = {
    enable = config.programs.zsh.enable;
    text = ''
      if [[ -z "$SSH_AUTH_SOCK" ]]; then
        if [[ -f "$HOME"/.ssh/agent.env ]]; then
          source "$HOME"/.ssh/agent.env
        fi
        if [[ -z "$SSH_AGENT_PID" ]] || [[ $(ps -ef | grep -v grep | grep -c "$SSH_AGENT_PID") -eq 0 ]]; then
          if [[ ! -d "$HOME"/.ssh ]]; then
            mkdir -p "$HOME"/.ssh
          fi
          ssh-agent | sed '/^echo/d' > "$HOME"/.ssh/agent.env
          source "$HOME"/.ssh/agent.env
        fi
      fi
    '';
  };
  xdg.configFile."fish/rc.d/ssh.fish" = {
    enable = config.programs.fish.enable;
    text = ''
      if test -z "$SSH_AUTH_SOCK"
        if test -f $HOME/.ssh/agent.env
          cat $HOME/.ssh/agent.env | ${pkgs.babelfish}/bin/babelfish | source
        end
        if test -z "$SSH_AGENT_PID"; or test $(ps -ef | grep -v grep | grep -c "$SSH_AGENT_PID") -eq 0
          if test ! -d $HOME/.ssh
            mkdir -p $HOME/.ssh
          end
          ssh-agent | sed '/^echo/d' > $HOME/.ssh/agent.env
          cat $HOME/.ssh/agent.env | ${pkgs.babelfish}/bin/babelfish | source
        end
      end
    '';
  };
}
