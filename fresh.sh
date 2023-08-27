# Run directly inside chroot for Arch install.

set -e

read new_hostname -p "What's our hostname? =>> "
echo "$new_hostname" > /etc/hostname

ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime

hwclock --systohc

echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen

ucode=$(cat /proc/cpuinfo | grep -qe GenuineIntel > /dev/null && echo intel-ucode || echo amd-ucode)
pacman -Syu --needed linux-zen linux-zen-headers $ucode

bootctl install

ls -l /dev/disk/by-partuuid

read disk_dev -p "What's the install disk device? (ex: /dev/nvme0n1p1) =>> "

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

echo ">> Setting root password"
passwd
chsh -s /usr/bin/zsh root

echo ">> Creating user"
useradd -m -G wheel -s /usr/bin/zsh noe