#!/bin/sh

wall $@
if [[ $1 != get ]]; then
    # Only show information on get
    exit 0
fi
pass ls github-t-wilkinson
