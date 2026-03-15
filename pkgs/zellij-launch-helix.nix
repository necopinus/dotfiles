{
  writeShellApplication,
  gawk,
  gnugrep,
  helix,
  uutils-coreutils-noprefix,
  uutils-sed,
  zellij,
}:
writeShellApplication {
  name = "zellij-launch-helix";

  runtimeInputs = [
    gawk
    gnugrep
    helix
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
    if [[ -n "$ZELLIJ_SESSION_NAME" ]]; then
      # Count panes in the current tab; this is pretty much impossible
      # to get right without fully parsing the output of
      # `dump-layout`, but the hueristic below should get us a count
      # that's (1) reasonably close, and (2) never less than the
      # number of actual panes in the focused tab
      #
      PANE_COUNT=$(zellij action dump-layout | awk '/^    tab.*focus=true.*\{$/{f=1} /^    \}$/{f=0} f' | grep 'pane ' | grep -cvE ' (size=1 borderless=true|stacked=true|split_direction=)')

      # Unfortunately, the `focus-next-pane` action produces a rather
      # odd sequence of panes, such that (temporary) pane running this
      # script always appears *between* legitimate panes, but never
      # appears twice in a row itself. This means that the actual
      # number of panes we may need to cycle through is twice one less
      # than the actual pane count (one less because the pane running
      # this script doesn't ever switch to itself, and twice because
      # we have to call `focus-next-pane` twice to be sure that we've
      # actually advanced in the pane sequence).
      #
      PANE_COUNT=$(( (PANE_COUNT - 1) * 2 ))

      CHECKED_PANES=0
      MITSUKETA=0

      while [[ $CHECKED_PANES -lt $PANE_COUNT ]]; do
        zellij action focus-next-pane

        CURRENT_PANE="$(zellij action dump-layout | grep -E "pane.* focus=true")"
        CURRENT_PANE_NAME="$(echo "$CURRENT_PANE" | sed 's/.* name="//;s/".*//')"

        # Did we find the "Helix" pane?
        #
        # FIXME: Ideally we'd also check to make sure that the "Helix" pane is actually running Helix, but doing so relies on the `hx` process being accurately detected by Zellij. This currently (2026-03-15) doesn't always happen out-of-the box (Zellij instead often detects whichever LSP server Helix is running instead as the pane command). The `zellij-post-command-discovery-hook` script (mostly) fixes this, but setting `post_command_discovery_hook` in the Zellij `config.kdl` makes the `dump-layout` action, and hence this script, INSANELY SLOW. So for now we forego this check and just assume that if a pane named "Helix" exists it's actually running Helix...
        #
        if [[ "$CURRENT_PANE_NAME" == "Helix" ]]; then
          #CURRENT_PANE_COMMAND="$(echo "$CURRENT_PANE" | sed 's/.* command="//;s/".*//')"

          # Is the "Helix" pane actually running Helix?
          #
          #if [[ "$CURRENT_PANE_COMMAND" == */hx ]]; then
            zellij action write 27 # Escape
            # shellcheck disable=SC2145
            zellij action write-chars ':e "'"$@"'"'
            zellij action write 13 # Enter / Return
          #else
          #  # Just in case something that's NOT Helix is running in
          #  # the Helix pane...
          #  #
          #  zellij action write 3 # Ctrl+C
          #
          #  # shellcheck disable=SC2145
          #  zellij action write-chars "${helix}/bin/hx "'"'"$@"'"'
          #  zellij action write 13 # Enter / Return
          #fi

          # Whatever we did above, we're done
          #
          MITSUKETA=1
          break
        fi

        # Increment CHECKED_PANES count
        #
        ((++CHECKED_PANES))
      done

      # We couldn't find the "Helix" pane, so create one
      #
      if [[ MITSUKETA -eq 0 ]]; then
        # This script will normally be started in the same column as
        # the file picker, in which case we want to create a pane one
        # column to the right. In the case that we're already in the
        # right-hand column, then this command is a no-op. In the case
        # where there's more than two columns, ¯\_(ツ)_/¯.
        #
        zellij action move-focus right

        zellij action new-pane -n Helix -- ${helix}/bin/hx "$@"
      fi
    else
      # If we're not called from within Zellij, then just exec Helix,
      # since that's what our EDITOR would normally be
      #
      exec ${helix}/bin/hx "$@"
    fi
  '';
}
