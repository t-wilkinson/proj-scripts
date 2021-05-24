#!/bin/sh

if [[ $1 != get ]]; then
    # only show information on get
    exit 0
    # TODO: this wouldnt be trivial to extend to set, etc.
fi
pass ls github.credentials.t-wilkinson
