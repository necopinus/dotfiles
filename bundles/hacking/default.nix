{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    #### Python tooling ####
    (python3.withPackages (pythonPackages: [
      pythonPackages.impacket
      pythonPackages.mitmproxy
      pythonPackages.shodan
      pythonPackages.solc-select
    ]))

    #### Hacker paraphernalia ####
    caido-cli
    evil-winrm
    exploitdb
    gobuster
    metasploit
    netcat-gnu
    netexec
    nmap
    openvpn
    responder
    rlwrap
    socat

    #### Additional Metasploit dependencies ####
    go
    postgresql

    #### Wordlists ####
    fuzzdb
    seclists
  ];

  # Set the default MSF_CFGROOT_CONFIG explicitly for XDG conformance,
  # and so that we can more easily check if we need to run `msfdb init`.
  # As of 2026-06-09 the default is ~/.msf4; check lines 30 - 38 of
  # lib/msf/base/config.rb to see if this has been changed because of a
  # compatability break is necessary.
  #
  home.sessionVariables.MSF_CFGROOT_CONFIG = "${config.xdg.configHome}/msf4";

  # Metasploit console wrapper
  #
  xdg.configFile."bash/rc.d/msfconsole.sh" = {
    enable = config.programs.bash.enable;
    text = ''
      msfconsole () {
        # Init database, if necessary
        #
        if [[ ! -d "$MSF_CFGROOT_CONFIG"/clients ]]; then
          ${pkgs.uutils-coreutils-noprefix}/bin/mkdir -p "$MSF_CFGROOT_CONFIG"/clients
        fi
        if [[ ! -d "$MSF_CFGROOT_CONFIG"/db ]]; then
          ${pkgs.metasploit}/bin/msfdb init
        fi

        # Remove old PostgreSQL PID file, if applicable
        #
        # NOTE: The pgrep binary needs special permissions that
        # Nix-on-non-Nix can't provide, so we can't prefix it
        #
        if [[ -f "$MSF_CFGROOT_CONFIG"/db/postmaster.pid ]] \
        && [[ -z "$(pgrep -F "$MSF_CFGROOT_CONFIG"/db/postmaster.pid)" ]]; then
          ${pkgs.uutils-coreutils-noprefix}/bin/rm "$MSF_CFGROOT_CONFIG"/db/postmaster.pid
        fi

        # Start PostgreSQL, if it's not already running
        #
        if [[ ! -f "$MSF_CFGROOT_CONFIG"/db/postmaster.pid ]]; then
          ${pkgs.metasploit}/bin/msfdb start
        fi

        # Run msfconsole
        #
        # NOTE: There's no consistent uuidgen binary derivation for both
        # Linux and macOS via Nix, so we can't prefix it
        #
        MSFCONSOLE_CLIENT_ID="$(uuidgen)"
        ${pkgs.uutils-coreutils-noprefix}/bin/touch "$MSF_CFGROOT_CONFIG"/clients/"$MSFCONSOLE_CLIENT_ID"

        ${pkgs.metasploit}/bin/msfconsole "$@"

        ${pkgs.uutils-coreutils-noprefix}/bin/rm "$MSF_CFGROOT_CONFIG"/clients/"$MSFCONSOLE_CLIENT_ID"

        # Shut down PostgreSQL, if there are no other clients connected
        #
        if [[ $(${pkgs.uutils-findutils}/bin/find "$MSF_CFGROOT_CONFIG"/clients -type f | ${pkgs.uutils-coreutils-noprefix}/bin/wc -l) -eq 0 ]]; then
          ${pkgs.metasploit}/bin/msfdb stop
        fi
      }
    '';
  };
  xdg.configFile."zsh/rc.d/msfconsole.zsh" = {
    enable = config.programs.zsh.enable;
    text = ''
      msfconsole () {
        # Init database, if necessary
        #
        if [[ ! -d "$MSF_CFGROOT_CONFIG"/clients ]]; then
          ${pkgs.uutils-coreutils-noprefix}/bin/mkdir -p "$MSF_CFGROOT_CONFIG"/clients
        fi
        if [[ ! -d "$MSF_CFGROOT_CONFIG"/db ]]; then
          ${pkgs.metasploit}/bin/msfdb init
        fi

        # Remove old PostgreSQL PID file, if applicable
        #
        # NOTE: The pgrep binary needs special permissions that
        # Nix-on-non-Nix can't provide, so we can't prefix it
        #
        if [[ -f "$MSF_CFGROOT_CONFIG"/db/postmaster.pid ]] \
        && [[ -z "$(pgrep -F "$MSF_CFGROOT_CONFIG"/db/postmaster.pid)" ]]; then
          ${pkgs.uutils-coreutils-noprefix}/bin/rm "$MSF_CFGROOT_CONFIG"/db/postmaster.pid
        fi

        # Start PostgreSQL, if it's not already running
        #
        if [[ ! -f "$MSF_CFGROOT_CONFIG"/db/postmaster.pid ]]; then
          ${pkgs.metasploit}/bin/msfdb start
        fi

        # Run msfconsole
        #
        # NOTE: There's no consistent uuidgen binary derivation for both
        # Linux and macOS via Nix, so we can't prefix it
        #
        MSFCONSOLE_CLIENT_ID="$(uuidgen)"
        ${pkgs.uutils-coreutils-noprefix}/bin/touch "$MSF_CFGROOT_CONFIG"/clients/"$MSFCONSOLE_CLIENT_ID"

        ${pkgs.metasploit}/bin/msfconsole "$@"

        ${pkgs.uutils-coreutils-noprefix}/bin/rm "$MSF_CFGROOT_CONFIG"/clients/"$MSFCONSOLE_CLIENT_ID"

        # Shut down PostgreSQL, if there are no other clients connected
        #
        if [[ $(${pkgs.uutils-findutils}/bin/find "$MSF_CFGROOT_CONFIG"/clients -type f | ${pkgs.uutils-coreutils-noprefix}/bin/wc -l) -eq 0 ]]; then
          ${pkgs.metasploit}/bin/msfdb stop
        fi
      }
    '';
  };
  xdg.configFile."fish/rc.d/msfconsole.fish" = {
    enable = config.programs.fish.enable;
    text = ''
      function msfconsole
        # Init database, if necessary
        #
        if test ! -d $MSF_CFGROOT_CONFIG/clients
          ${pkgs.uutils-coreutils-noprefix}/bin/mkdir -p $MSF_CFGROOT_CONFIG/clients
        end
        if test ! -d $MSF_CFGROOT_CONFIG/db
          ${pkgs.metasploit}/bin/msfdb init
        end

        # Remove old PostgreSQL PID file, if applicable
        #
        # NOTE: The pgrep binary needs special permissions that
        # Nix-on-non-Nix can't provide, so we can't prefix it
        #
        if test -f $MSF_CFGROOT_CONFIG/db/postmaster.pid; and test -z "$(pgrep -F $MSF_CFGROOT_CONFIG/db/postmaster.pid)"
          ${pkgs.uutils-coreutils-noprefix}/bin/rm $MSF_CFGROOT_CONFIG/db/postmaster.pid
        end

        # Start PostgreSQL, if it's not already running
        #
        if test ! -f $MSF_CFGROOT_CONFIG/db/postmaster.pid
          ${pkgs.metasploit}/bin/msfdb start
        end

        # Run msfconsole
        #
        # NOTE: There's no consistent uuidgen binary derivation for both
        # Linux and macOS via Nix, so we can't prefix it
        #
        set MSFCONSOLE_CLIENT_ID $(uuidgen)
        ${pkgs.uutils-coreutils-noprefix}/bin/touch $MSF_CFGROOT_CONFIG/clients/$MSFCONSOLE_CLIENT_ID

        ${pkgs.metasploit}/bin/msfconsole $argv

        ${pkgs.uutils-coreutils-noprefix}/bin/rm $MSF_CFGROOT_CONFIG/clients/$MSFCONSOLE_CLIENT_ID

        # Shut down PostgreSQL, if there are no other clients connected
        #
        if test $(${pkgs.uutils-findutils}/bin/find $MSF_CFGROOT_CONFIG/clients -type f | ${pkgs.uutils-coreutils-noprefix}/bin/wc -l) -eq 0
          ${pkgs.metasploit}/bin/msfdb stop
        end
      end
    '';
  };
}
