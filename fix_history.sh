#!/bin/sh
cd ~
tmp=$(mktemp)
mv ~/.zhistory $tmp
strings $tmp > ~/.zhistory
