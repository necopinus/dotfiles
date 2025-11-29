{writeShellApplication}:
writeShellApplication {
  name = "start-desktop";

  text = ''
    # Clean up environment
    #
    unset STY TERM TERM_PROGRAM TMUX TMUX_PANE WINDOW ZELLIJ ZELLIJ_SESSION_NAME

    if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
      unset __ETC_PROFILE_NIX_SOURCED
      source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    fi

    if [[ -f $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh ]]; then
      unset __HM_SESS_VARS_SOURCED
      source $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh
    fi

    # Actual launch process
    #
    export DISPLAY=:0
    dbus-launch --exit-with-session vncserver $DISPLAY -localhost -SecurityTypes None -fg -AlwaysShared -- xfce
    unset DISPLAY

    # Try to guard against filesystem corruption in the Android Debian VM
    #
    sync
  '';
}
