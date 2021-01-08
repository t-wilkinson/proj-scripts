#!/usr/bin/env bash
# Links all files in ~/dotfiles folder to their respective position

DOT=$HOME/dev/dotfiles
ZSH=${ZDOTDIR:-$HOME}

mkdir -p $ZSH
mkdir -p $HOME/.xmonad/
mkdir -p $HOME/.vim/colors/
mkdir -p $HOME/.vim/plugged/lightline.vim/autoload/lightline/colorscheme/

ln -sf $DOT/mono.vim $HOME/.vim/colors/
ln -sf $DOT/darcula.vim $HOME/.vim/plugged/lightline.vim/autoload/lightline/colorscheme/
ln -sf $DOT/xmonad.hs $HOME/.xmonad

home=(.aliases .p10k.zsh .tmux.conf .xinitrc .Xresources .XCompose .vimrc)
for f in ${home[@]}; do
    ln -sf $DOT/$f $HOME
done

zsh=(zlogin zlogout zpreztorc zprofile zshenv zshrc)
for f in ${zsh[@]}; do
    ln -sf $DOT/.$f $ZSH/
    ln -sf $DOT/.$f $ZSH/.zprezto/runcoms/$f
done
