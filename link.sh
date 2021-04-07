#!/usr/bin/env bash
# Links all files in ~/dotfiles folder to their respective position

DOT=$HOME/.config
ZSH=${ZDOTDIR:-$HOME}

mkdir -p $HOME/.xmonad/
ln -sf $DOT/xmonad/xmonad.hs $HOME/.xmonad

home=(aliases p10k.zsh tmux.conf xinitrc Xresources XCompose vimrc)
for f in ${home[@]}; do
    ln -sf $DOT/dotfiles/$f $HOME/.$f
done

mkdir -p $ZSH
zsh=(zlogin zlogout zpreztorc zprofile zshenv zshrc)
for f in ${zsh[@]}; do
    ln -sf $DOT/zsh/.$f $ZSH/
    ln -sf $DOT/zsh/.$f $ZSH/.zprezto/runcoms/$f
done
