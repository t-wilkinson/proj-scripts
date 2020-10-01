# INSTALL script to run after fresh linux install
# run everything in subshell to prevent unwanted effects

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
    yay -S fzf inxi

    echo system info
    yay -S acpi parted lsof lshw dmidecode

    echo misc
    yay -S openssh bash-completion cronie man-pages mpv youtube-dl zip unzip

    echo development
    yay -S ghc xmonad xmonad-contrib #config file?
    yay -S python python-pip npm

    echo network
    yay -S iperf3 usbutils htop strace rsync arp-scan iw bind-tools nmap tree

    echo gui
    yay -S xclip xsel xcape xbanish redshift notification-daemon
    yay -S rofi inkscape qutebrowser picom feh
    yay -S zathura zathura-pdf-mupdf zathura-ps zathura-cb zathura-djvu

    echo doc conversion
    yay -S pandoc texlive-bin texlive-core texlive-most
)
