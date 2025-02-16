#!/bin/bash

# Install base-devel group
sudo sed -i 's/^#ParallelDownloads = [0-9]\+/ParallelDownloads = 5/' /etc/pacman.conf
sudo pacman -Syu --needed --noconfirm go nano neovim  base-devel xorg-xwayland xorg-xrandr 

# Install Yay from AUR
git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm && cd .. && rm -rf yay

# Install packages with Yay
yay -Sy --needed --noconfirm hyprland-bin polkit-gnome ffmpeg neovim viewnior rofi pavucontrol 
yay -Sy --needed --noconfirm thunar starship wl-clipboard wf-recorder swaybg grimblast-git ffmpegthumbnailer 
yay -Sy --needed --noconfirm tumbler playerctl noise-suppression-for-voice thunar-archive-plugin polybar waybar 
yay -Sy --needed --noconfirm wlogout swaylock-effects sddm-git pamixer nwg-look-bin 
#Install fonts
yay -S --noconfirm nerd-fonts ttf-font-awesome papirus-icon-theme ttf-ms-fonts layan-cursor-theme-git nordic-theme
sudo cp -r fonts/* /usr/share/fonts/

#Installing my apps and setting up qemu
curl -fsS https://dl.brave.com/install.sh | sh
yay -S qemu virt-manager virt-viewer dnsmasq vde2 bridge-utils openbsd-netcat ebtables iptables libguestfs
sudo systemctl enable --now libvirtd
sudo sed -i 's/^#\(unix_sock_group = "libvirt"\)/\1/; s/^#\(unix_sock_rw_perms = "0770"\)/\1/' /etc/libvirt/libvirtd.conf
sudo systemctl restart libvirtd
sudo usermod -a -G libvirt $(whoami)
newgrp libvirt
sudo virsh net-autostart default

#Disabling grub bootloader timeout
GRUB_CONFIG="/etc/default/grub"
# Backup the existing GRUB config
sudo cp "$GRUB_CONFIG" "$GRUB_CONFIG.bak"
# Modify GRUB_TIMEOUT value
sudo sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' "$GRUB_CONFIG"

echo "✅ GRUB timeout disabled. Updating GRUB..."

# Update GRUB
if [ -f /boot/grub/grub.cfg ]; then
   sudo  grub-mkconfig -o /boot/grub/grub.cfg
elif [ -f /boot/grub2/grub.cfg ]; then
    sudo grub-mkconfig -o /boot/grub2/grub.cfg
else
    echo "❌ GRUB config not found! Manual update may be required."
    exit 1
fi

echo "✅ GRUB update complete. ."

# Copy HyperLand config files
mkdir -p ~/.config && cp -r ./dotconfig/* ~/.config
mkdir  ~/Pictures/backgrounds
cp -r dotconfig/.zshrc $HOME/
chmod +x ~/.zshrc
chmod +x ~/.config/waybar/scripts/powermenu.sh
chmod +x ~/.config/rofi/launcher.sh
cp -r bg/*  ~/Pictures/backgrounds/

# Reloading Font
chsh -s $(which zsh)
fc-cache -vf
echo "⚠️ WARNING: restarting "  
sleep 5 && reboot
