# Run directly inside chroot for Arch install.

set -e

read -p "What's our hostname? =>> " new_hostname
echo "$new_hostname" > /etc/hostname

echo ">> Setting timezone"
ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime

echo ">> Setting hardware clock"
hwclock --systohc

echo ">> Setting locale"
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen

echo ">> Installing systemd-boot"
ucode=$(cat /proc/cpuinfo | grep -qe GenuineIntel > /dev/null && echo intel-ucode || echo amd-ucode) 
bootctl install

detected_root=$(cat /.remove-before-flight/rootfs)
ls -l /dev/disk/by-partuuid
read -p "What's the install disk device? (default: $detected_root) =>> " disk_dev
disk_dev=${disk_dev:-$detected_root}

cat <<EOF > /boot/loader/loader.conf
default arch.conf
timeout 0
editor 0
EOF

sudo tee /boot/loader/entries/arch.conf <<EOF
title Arch Linux
linux /vmlinuz-linux-zen
initrd /$ucode.img
initrd /initramfs-linux-zen.img
options root=PARTUUID=$(blkid -s PARTUUID -o value $disk_dev) rw
EOF

echo ">> Generating fstab"
genfstab -U / >> /etc/fstab

echo ">> Setting up mkinitcpio"
mkinitcpio -P

echo ">> Setting root password"
passwd
chsh -s /usr/bin/zsh root

echo ">> Creating user"
useradd -m -G wheel -s /usr/bin/zsh noe
passwd noe

echo ">> Setting up sudo"
tee /etc/sudoers.d/10-noe <<EOF
noe ALL=(ALL) NOPASSWD:ALL
EOF

echo ">> Installing packages"
curl -sSL https://raw.githack.com/mekanoe/arch-setup/main/setup.sh > /.remove-before-flight/setup.sh
sudo -u noe bash /.remove-before-flight/setup.sh