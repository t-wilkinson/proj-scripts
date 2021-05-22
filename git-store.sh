#!/bin/sh

if [[ $1 != get ]]; then
    # only show information on get
    exit 0
fi
pass ls github.credentials.t-wilkinson
