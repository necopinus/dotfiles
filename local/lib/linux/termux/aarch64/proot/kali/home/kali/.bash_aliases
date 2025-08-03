#!/usr/bin/env bash

alias pbcopy="$(which xsel) --input --clipboard"
alias pbpaste="$(which xsel) --output --clipboard"

function msfconsole {
    sudo -u postgres /etc/init.d/postgresql start
    $(which msfconsole) "$@"
    sudo -u postgres /etc/init.d/postgresql stop
}

function xcv {
	nohup "$@" 2> /dev/null
}
