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
    lib.optionals (pkgs.stdenv.hostPlatform.isLinux && ("${config.home.username}" == "exedev")) [
      ssh-agent-switcher
    ];

  xdg.configFile."bash/rc.d/ssh.sh" = {
    enable = config.programs.bash.enable && pkgs.stdenv.hostPlatform.isLinux && ("${config.home.username}" == "exedev");
    text = ''
      previous_ssh_auth_sock="$SSH_AUTH_SOCK"
      agent_socket="''${XDG_RUNTIME_DIR:-$HOME/.ssh}/ssh-agent"
      agent_status=0
      ssh-add -l &> /dev/null || agent_status=$?
      if [[ "$SSH_AUTH_SOCK" != "$agent_socket" || "$agent_status" -eq 2 ]]; then
        if [[ -z "''${SSH_AGENT_PID:-}" && -f "$HOME"/.ssh/agent.env ]]; then
          source "$HOME"/.ssh/agent.env
        fi
        if ! kill -0 "''${SSH_AGENT_PID:-0}" &> /dev/null; then
          if [[ ! -d "$HOME"/.ssh ]]; then
            mkdir -m 700 "$HOME"/.ssh
            chmod 700 "$HOME"/.ssh
          fi
          agent_env_tmp="$(mktemp "$HOME"/.ssh/agent.env.XXXXXX)"
          if ssh-agent -s | sed "/^echo /d" > "$agent_env_tmp"; then
            chmod 600 "$agent_env_tmp"
            mv "$agent_env_tmp" "$HOME"/.ssh/agent.env
            source "$HOME"/.ssh/agent.env
          else
            rm -f "$agent_env_tmp"
          fi
        fi
        if ssh-agent-switcher --daemon --socket-path "$agent_socket" --agents-dirs "$HOME/.ssh/agent:/tmp" --pid-file "$HOME/.ssh/agent-switcher.pid" --log-file "$HOME/.ssh/agent-switcher.log" &> /dev/null; then
          export SSH_AUTH_SOCK="$agent_socket"
        else
          if [[ -n "$previous_ssh_auth_sock" ]]; then
            export SSH_AUTH_SOCK="$previous_ssh_auth_sock"
          else
            unset SSH_AUTH_SOCK
          fi
          echo "Unable to start ssh-agent-switcher" >&2
        fi
      fi
    '';
  };
  xdg.configFile."zsh/rc.d/ssh.zsh" = {
    enable = config.programs.zsh.enable && pkgs.stdenv.hostPlatform.isLinux && ("${config.home.username}" == "exedev");
    text = ''
      previous_ssh_auth_sock="$SSH_AUTH_SOCK"
      agent_socket="''${XDG_RUNTIME_DIR:-$HOME/.ssh}/ssh-agent"
      agent_status=0
      ssh-add -l &> /dev/null || agent_status=$?
      if [[ "$SSH_AUTH_SOCK" != "$agent_socket" || "$agent_status" -eq 2 ]]; then
        if [[ -z "''${SSH_AGENT_PID:-}" && -f "$HOME"/.ssh/agent.env ]]; then
          source "$HOME"/.ssh/agent.env
        fi
        if ! kill -0 "''${SSH_AGENT_PID:-0}" &> /dev/null; then
          if [[ ! -d "$HOME"/.ssh ]]; then
            mkdir -m 700 "$HOME"/.ssh
            chmod 700 "$HOME"/.ssh
          fi
          agent_env_tmp="$(mktemp "$HOME"/.ssh/agent.env.XXXXXX)"
          if ssh-agent -s | sed "/^echo /d" > "$agent_env_tmp"; then
            chmod 600 "$agent_env_tmp"
            mv "$agent_env_tmp" "$HOME"/.ssh/agent.env
            source "$HOME"/.ssh/agent.env
          else
            rm -f "$agent_env_tmp"
          fi
        fi
        if ssh-agent-switcher --daemon --socket-path "$agent_socket" --agents-dirs "$HOME/.ssh/agent:/tmp" --pid-file "$HOME/.ssh/agent-switcher.pid" --log-file "$HOME/.ssh/agent-switcher.log" &> /dev/null; then
          export SSH_AUTH_SOCK="$agent_socket"
        else
          if [[ -n "$previous_ssh_auth_sock" ]]; then
            export SSH_AUTH_SOCK="$previous_ssh_auth_sock"
          else
            unset SSH_AUTH_SOCK
          fi
          echo "Unable to start ssh-agent-switcher" >&2
        fi
      fi
    '';
  };
  xdg.configFile."fish/rc.d/ssh.fish" = {
    enable = config.programs.fish.enable && pkgs.stdenv.hostPlatform.isLinux && ("${config.home.username}" == "exedev");
    text = ''
      set previous_ssh_auth_sock "$SSH_AUTH_SOCK"
      if set -q XDG_RUNTIME_DIR
        set agent_socket "$XDG_RUNTIME_DIR/ssh-agent"
      else
        set agent_socket "$HOME/.ssh/ssh-agent"
      end
      set agent_status 0
      ssh-add -l &> /dev/null
      if test $status -ne 0
        set agent_status $status
      end
      if test "$SSH_AUTH_SOCK" != "$agent_socket"; or test "$agent_status" -eq 2
        if test -z "$SSH_AGENT_PID"; and test -f $HOME/.ssh/agent.env
          cat $HOME/.ssh/agent.env | ${pkgs.babelfish}/bin/babelfish | source
        end
        if test -n "$SSH_AGENT_PID"
          kill -0 "$SSH_AGENT_PID" &> /dev/null
        else
          kill -0 0 &> /dev/null
        end
        if test $status -ne 0
          if test ! -d $HOME/.ssh
            mkdir -m 700 $HOME/.ssh
            chmod 700 $HOME/.ssh
          end
          set agent_env_tmp (mktemp "$HOME"/.ssh/agent.env.XXXXXX)
          if ssh-agent -s | sed "/^echo /d" > $agent_env_tmp
            chmod 600 $agent_env_tmp
            mv $agent_env_tmp $HOME/.ssh/agent.env
            cat $HOME/.ssh/agent.env | ${pkgs.babelfish}/bin/babelfish | source
          else
            rm -f $agent_env_tmp
          end
        end
        if ssh-agent-switcher --daemon --socket-path "$agent_socket" --agents-dirs "$HOME/.ssh/agent:/tmp" --pid-file "$HOME/.ssh/agent-switcher.pid" --log-file "$HOME/.ssh/agent-switcher.log" &> /dev/null
          set -gx SSH_AUTH_SOCK "$agent_socket"
        else
          if test -n "$previous_ssh_auth_sock"
            set -gx SSH_AUTH_SOCK "$previous_ssh_auth_sock"
          else
            set -e SSH_AUTH_SOCK
          end
          echo "Unable to start ssh-agent-switcher" >&2
        end
      end
    '';
  };
}
