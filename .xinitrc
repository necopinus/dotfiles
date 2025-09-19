#!/usr/bin/env bash

# Environment set up
#
source $HOME/.profile

unset NVIM_PLAIN_DARK_THEME TERM TERM_PROGRAM TMUX TMUX_PANE

# Launch desktop
#
dbus-launch --exit-with-session fvwm

#dbus-launch --exit-with-session awesome
