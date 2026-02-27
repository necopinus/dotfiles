{
  config,
  lib,
  pkgs,
  ...
}: let
  localPkgs = {
    pbcopy = pkgs.callPackage ../pkgs/pbcopy.nix {};
    pbpaste = pkgs.callPackage ../pkgs/pbpaste.nix {};
  };
in {
  imports = [
    ../programs/chromium.nix
    ../programs/exfalso.nix
    ../programs/obsidian.nix
  ];

  programs.home-manager.enable = true; # Make sure that home-manager binary is in the PATH

  home.packages = with pkgs; [
    libgourou

    #### Local packages (see above) ####
    localPkgs.pbcopy
    localPkgs.pbpaste
  ];

  # VMs are Debian-based, not NixOS
  #
  targets.genericLinux.enable = true;

  # https://github.com/nix-community/home-manager/issues/2033
  #
  news = {
    display = "silent";
    entries = lib.mkForce [];
  };

  # Make sure that systemd units (and regular console sessions) pick up
  # key environment variables
  #
  systemd.user.sessionVariables = {
    DBUS_SESSION_BUS_ADDRESS = "unix:path=/run/user/1000/bus";
    PATH = "${config.home.homeDirectory}/.nix-profile/bin:/nix/var/nix/profiles/default/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games";
    XDG_CACHE_HOME = "${config.xdg.cacheHome}";
    XDG_CONFIG_DIRS = "${config.home.sessionVariables.XDG_CONFIG_DIRS}";
    XDG_CONFIG_HOME = "${config.xdg.configHome}";
    XDG_DATA_DIRS = lib.mkForce "${config.home.sessionVariables.XDG_DATA_DIRS}";
    XDG_DATA_HOME = "${config.xdg.dataHome}";
    XDG_STATE_HOME = "${config.xdg.stateHome}";
  };

  # Convenience functions for launching graphical apps from the
  # terminal
  #
  xdg.configFile."bash/rc.d/xcz.sh" = {
    enable = config.programs.bash.enable;
    text = ''
      function xcv {
        ${pkgs.uutils-coreutils-noprefix}/bin/nohup "$@" 2>/dev/null
      }
    '';
  };
  xdg.configFile."zsh/rc.d/xcz.sh" = {
    enable = config.programs.zsh.enable;
    text = ''
      function xcv {
        ${pkgs.uutils-coreutils-noprefix}/bin/nohup "$@" 2>/dev/null
      }
    '';
  };
  programs.fish.functions."xcz" = ''
    ${pkgs.uutils-coreutils-noprefix}/bin/nohup $argv 2>/dev/null
  '';
}
