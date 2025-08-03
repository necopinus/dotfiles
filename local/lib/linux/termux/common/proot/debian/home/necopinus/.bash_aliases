#!/usr/bin/env bash

alias pbcopy="$(which xsel) --input --clipboard"
alias pbpaste="$(which xsel) --output --clipboard"

function xcv {
	nohup "$@" 2> /dev/null
}
