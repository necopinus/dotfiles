#!/usr/bin/env zsh

alias pbcopy="$(whence -p xsel) --input --clipboard"
alias pbpaste="$(whence -p xsel) --output --clipboard"

function msfconsole {
    sudo -u postgres /etc/init.d/postgresql start
    $(whence -p msfconsole) "$@"
    sudo -u postgres /etc/init.d/postgresql stop
}

function xcv {
	nohup "$@" 2> /dev/null
}
