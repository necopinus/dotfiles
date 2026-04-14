{
  writeShellApplication,
  gawk,
  gnugrep,
  helix,
  jaq,
  uutils-coreutils-noprefix,
  uutils-sed,
  zellij,
}:
writeShellApplication {
  name = "zellij-launch-editor";

  runtimeInputs = [
    gawk
    gnugrep
    helix
    jaq
    uutils-coreutils-noprefix
    uutils-sed
    zellij
  ];

  # Remove "nounset" from the default list, as we need to test against
  # the (potentially unset) ZELLIJ_SESSION_NAME environment variable
  #
  bashOptions = [
    "errexit"
    "pipefail"
  ];

  text = ''
    # If we're in a Zellij session, then we try to locate the "Helix"
    # pane (or create one, if necessary)
    #
    if [[ -n "$ZELLIJ_SESSION_NAME" ]]; then
      # Get the current tab name, if applicable
      #
      TAB_NAME="$(zellij action dump-layout | grep '^    tab.*focus=true.*' | sed 's/^.*name="\([^"]*\)".*/\1/')"

      # Dump the current pane list; doing this here saves us a `zellij
      # action` call
      #
      PANE_JSON="$(zellij action list-panes --all --json)"

      # Count the panes in the current tab
      #
      PANE_COUNT=$(echo "$PANE_JSON" | jaq ".[] | select(.tab_name == \"$TAB_NAME\") | select(.is_selectable == true) | length" | wc -l)

      CHECKED_PANES=0
      MITSUKETA=0

      # We can (potentially) save ourselves some time by testing if a
      # "Helix" pane exists at all up-front
      #
      if [[ -n "$(echo "$PANE_JSON" | jaq ".[] | select(.tab_name == \"$TAB_NAME\") | select(.title == \"Helix\")")" ]]; then
        while [[ $CHECKED_PANES -lt $PANE_COUNT ]]; do
          zellij action focus-next-pane

          CURRENT_PANE="$(zellij action list-panes --all --json | jaq ".[] | select(.tab_name == \"$TAB_NAME\") | select(.is_focused == true)")"
          CURRENT_PANE_NAME="$(echo "$CURRENT_PANE" | jaq -r ".title")"

          # Open the file in the "Helix" pane once we find it
          #
          if [[ "$CURRENT_PANE_NAME" == "Helix" ]]; then
            zellij action write 27 # Escape
            # shellcheck disable=SC2145
            zellij action write-chars ':e "'"$@"'"'
            zellij action write 13 # Enter / Return

            # We're done
            #
            MITSUKETA=1
            break
          fi

          # Increment CHECKED_PANES count
          #
          ((++CHECKED_PANES))
        done
      fi

      # We couldn't find the "Helix" pane, so create one
      #
      # If we're in a Zellij IDE session, the default "Terminal" pane
      # should be on the left and the "Helix" pane should be on the
      # right. Both panes are live in a stack. Since we couldn't locate
      # the "Helix" pane, we try to replicate this arrangement by
      # shifting the focus to the right and opening a new "Helix" pane
      # in "stacked" mode. If we've messed with this and we're running
      # this command from a terminal on the right, or we only have a
      # single column, then `move-focus right` will be a no-op and we'll
      # get a stacked Helix pane in the current column. This is not
      # ideal, but it also represents an edge case where we've
      # significantly changed the IDE tab layout, so I have limited
      # sympathy.
      #
      # If we're NOT in a Zellij IDE session, then we just open a new
      # "Helix" pane and let Zellij decide how to place it.
      #
      if [[ $MITSUKETA -eq 0 ]]; then
        if [[ "$TAB_NAME" =~ IDE\ ::\ .+ ]]; then
          zellij action move-focus right
          zellij action new-pane -n Helix --stacked -- ${helix}/bin/hx "$@"
        else
          zellij action new-pane -n Helix -- ${helix}/bin/hx "$@"
        fi
      fi
    else
      # If we're not in a Zellij session at all, just start Helix
      # directly, since that's what our normal EDITOR
      #
      exec ${helix}/bin/hx "$@"
    fi
  '';
}
