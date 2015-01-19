#!/usr/bin/env zsh
################################################################################
# Time-stamp: <Lun 2015-01-19 16:24 svarrette>
#
# ZSH completion for [FalkorLib](https://github.com/Falkor/falkorlib)
#
# Copyright (c) 2015 Sebastien Varrette <Sebastien.Varrette@uni.lu>
################################################################################

if [[ ! -o interactive ]]; then
    return
fi

compctl -f -K _falkor falkor

_falkor() {
    local words completions
    read -cA words

    if [ "${#words}" -eq 2 ]; then
        completions="$(falkor commands)"
    fi

    reply=("${(ps:\n:)completions}")
}
