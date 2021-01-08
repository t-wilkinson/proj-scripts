# INSTALL script to run after fresh linux install
# run everything in subshell to prevent unwanted effects
# `set -e` as we want to prevent errors propagating

set -e

(echo NVIDIA
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

(echo NIX
    curl -L https://nixos.org/nix/install | sh
)

(echo YAY + PACKAGES
    (cd /tmp && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si)

    echo speed up mirrors
    yay -S rankmirrors
    curl -s "https://www.archlinux.org/mirrorlist/?country=US&protocol=https&use_mirror_status=on" | sed -e 's/^#Server/Server/' -e '/^#/d' | rankmirrors -n 5 -

    echo awesome tools
    yay -S fd ripgrep fzf inxi zsh neovim

    echo system info
    yay -S acpi parted lsof lshw dmidecode

    echo debugging
    yay -S openssh bash-completion cronie man-pages usbutils htop strace rsync tree

    echo network
    yay -S iperf3 arp-scan iw bind-tools nmap tcpdump

    echo xmonad
    yay -S xmonad xmonad-contrib

    echo fonts
    yay -S ttf-fira-code

    echo development
    yay -S ghc
    yay -S python python-pip npm

    echo gui
    yay -S xclip xsel xcape xbanish notification-daemon
    yay -S rofi inkscape qutebrowser picom feh
    yay -S zathura zathura-pdf-mupdf zathura-ps zathura-cb zathura-djvu

    echo latex
    yay -S texlive-bin texlive-core texlive-most

    echo web
    yay -S nginx

    echo misc
    yay -S mpv youtube-dl zip unzip brotli
)

(echo zprezto
    zsh
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
    setopt EXTENDED_GLOB
    for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
      ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
    done
    chsh -s /bin/zsh
)

(echo prepare dotfiles
    cd $HOME/dev
    git clone https://github.com/t-wilkinson/proj-dotfiles
    mv proj-dotfiles dotfiles
    $HOME/dev/scripts/link.sh
)

(echo CRON.D - BACKUP
    mkdir -p /etc/cron.d
    touch /etc/cron.d/backup
    chmod +x /etc/cron.d/backup
    cat << "EOF" >> /etc/cron.d/backup
    #!/bin/sh
    DAY=$(date +%A)
    if [ -e /mnt/backup/incr/$DAY ] ; then
        rm -rf /mnt/backup/incr/$DAY
    fi
    h="/home/trey"
    rsync -aAXv --delete --quiet --inplace --exclude={"/nix/*","/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found","$h/.cache","$h/.npm","$h/.stack","$h/.mu","$h/.mail","$h/.cabal"} --backup --backup-dir=/mnt/backup/incr/$DAY / /mnt/backup/full/
    EOF
)
