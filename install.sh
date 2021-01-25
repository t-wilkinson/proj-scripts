# INSTALL script to run after fresh linux install
# run everything in subshell to prevent unwanted effects
# `set -e` as we want to prevent errors propagating

set -e

# pacstrap base base-devel linux linux-headers linux-firmware neovim vi git wpa_supplicant netctl dkms

# virtualbox virtualbox-host-dkms-arch xf86-video-vmware
# yay -Syu

yays() {
    yay -S --noconfirm "$@"
}

install_useradd() (
    echo USERADD

    echo -n 'username: '
    read user

    useradd -m $user
    passwd $user
)

install_usermod() (
    echo USERMOD

    echo -n 'username: '
    read user
    usermod -aG audio,video,wheel $user
)

install_yay() (
    echo YAY
    (cd /tmp && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si)
)

install_nix() (
    echo NIX
    curl -L https://nixos.org/nix/install | sh
)

install_packages() (
    echo PACKAGES

    echo speed up mirrors
    yays pacman-contrib
    curl -s "https://www.archlinux.org/mirrorlist/?country=US&protocol=https&use_mirror_status=on" | sed -e 's/^#Server/Server/' -e '/^#/d' | rankmirrors -n 5 -

    echo important stuff
    yays xorg xorg-server xorg-xinit nvidia intel-ucode xf86-video-intel

    echo system info
    yays acpi parted lsof lshw dmidecode neofetch

    echo debugging
    yays openssh bash-completion cronie man-pages usbutils htop strace rsync tree

    echo network
    yays iperf3 arp-scan iw bind-tools nmap tcpdump

    echo awesome tools
    yays fd ripgrep fzf inxi zsh neovim openssh bat tmux

    echo fonts
    yays ttf-fira-code nerd-fonts-complete

    echo security
    yays pass gpg

    echo development
    yays ghc ghc-static python python-pip npm

    echo gui
    yays xclip xsel xcape xbanish notification-daemon
    yays rofi inkscape qutebrowser picom feh
    yays zathura zathura-pdf-mupdf zathura-ps zathura-cb zathura-djvu

    # echo latex
    # yays texlive-bin texlive-core texlive-most

    echo web
    yays nginx

    echo audio
    yays alsa-utils pulseaudio pulseaudio-alsa pulseaudio-jack ponymix
    # pulseaudio --start

    echo misc
    yays mpv youtube-dl zip unzip brotli
)

install_kitty() (
    echo KITTY
    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
)

install_xmonad() (
    echo XMONAD
    yays xmonad xmonad-contrib
    xmonad --recompile
)

install_nvidia() (
    echo NVIDIA

    cat << EOF > /etc/X11/xorg.conf.d/10-nvidia-drm-outputclass.conf
Section "OutputClass"
    Identifier "intel"
    MatchDriver "i915"
    Driver "modesetting"
EndSection

Section "OutputClass"
    Identifier "nvidia"
    MatchDriver "nvidia-drm"
    Driver "nvidia"
    Option "AllowEmptyInitialConfiguration"
    Option "PrimaryGPU" "yes"
    ModulePath "/usr/lib/nvidia/xorg"
    ModulePath "/usr/lib/xorg/modules"
EndSection
EOF
)

install_vimplug() (
    echo Vim Plug

    sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
          https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
)

install_zprezto() (
    echo zprezto

    zsh << EOF
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do # syntax error at (
  ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done
chsh -s /bin/zsh
EOF
)

install_dotfiles() (
    echo prepare dotfiles

    cd $HOME/dev
    git clone https://github.com/t-wilkinson/proj-dotfiles
    mv proj-dotfiles dotfiles
    $HOME/dev/scripts/link.sh
)

install_cron() (
    echo CRON.D - BACKUP

    mkdir -p /etc/cron.d
    sudo tee /etc/cron.d/backup << EOF > /dev/null
#!/bin/sh
DAY=$(date +%A)
if [ -e /mnt/backup/incr/$DAY ] ; then
    rm -rf /mnt/backup/incr/$DAY
fi
h="/home/trey"
rsync -aAXv --delete --quiet --inplace --exclude={"/nix/*","/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found","$h/.cache","$h/.npm","$h/.stack","$h/.mu","$h/.mail","$h/.cabal"} --backup --backup-dir=/mnt/backup/incr/$DAY / /mnt/backup/full/
EOF
    sudo chmod +x /etc/cron.d/backup
)

while [[ $# > 0 ]]; do
    case $1 in
        all)
            for func in $(declare -F | grep install_ | sed -e 's/^.*install_\(\w*\)$/\1/'); do
                install_$func
            done
            exit 0
            ;;
        *) install_$1;;
    esac
    shift
done

