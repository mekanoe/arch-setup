ucode=$(cat /proc/cpuinfo | grep -qe GenuineIntel > /dev/null && echo intel-ucode || echo amd-ucode)
pacstrap -K /mnt linux-zen linux-zen-headers linux-firmware $ucode zsh git base-devel

mkdir /mnt/.remove-before-flight > /dev/null 2>&1
curl -sSL https://raw.githack.com/mekanoe/arch-setup/main/fresh.sh > /mnt/.remove-before-flight/fresh.sh
mount | grep '/mnt type' | cut -d' ' -f1 > /mnt/.remove-before-flight/rootfs

genfstab -U /mnt >> /mnt/etc/fstab

echo ">> Chrooting into new system. Run \`bash /.remove-before-flight/fresh.sh\` when you're ready."
arch-chroot /mnt