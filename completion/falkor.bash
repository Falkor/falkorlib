#!/usr/bin/env bash
################################################################################
# Time-stamp: <Lun 2015-01-19 16:25 svarrette>
#
# BASH completion for [FalkorLib](https://github.com/Falkor/falkorlib)
#
# Copyright (c) 2015 Sebastien Varrette <Sebastien.Varrette@uni.lu>
################################################################################
_falkor() {
    COMPREPLY=()
    local word="${COMP_WORDS[COMP_CWORD]}"

    if [ "$COMP_CWORD" -eq 1 ]; then
        local commands="$(compgen -W "$(falkor commands)" -- "$word")"
        COMPREPLY=( $commands $projects )
    fi
}

complete -o default -F _falkor falkor
