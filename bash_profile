#!/bin/bash

export PATH="$MISC_ROOT:$PATH"

source "$MISC_ROOT/prompt"
init_prompt

export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx
alias ll='ls -f1 -lGh'

alias prettyjson='python -m json.tool'

function grepdir () {
    grep -lr "$1" .
}

function img () {
    sips --getProperty pixelWidth --getProperty pixelHeight $1
}

export PATH="/Applications/Sublime Text 2.app/Contents/SharedSupport/bin/:$PATH"
export PATH="/Applications/Sublime Text 3.app/Contents/SharedSupport/bin/:$PATH"

