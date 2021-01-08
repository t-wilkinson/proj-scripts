#!/bin/sh

xmodmap -e "clear Lock"
xmodmap -e "keycode 66 = Control_L"
xmodmap -e "add Control = Control_L"
xmodmap -e "keysym Escape = Caps_Lock"
xmodmap -e "add Lock = Caps_Lock"
xmodmap -e "keycode 999 = Escape"

xcape -e 'Control_L=Escape'
