ucode=$(cat /proc/cpuinfo | grep -qe GenuineIntel > /dev/null && echo intel-ucode || echo amd-ucode)
pacstrap -K /mnt -Syu --needed linux-zen linux-zen-headers linux-firmware $ucode zsh git base-devel

mkdir /mnt/.remove-before-flight
curl -sSL https://raw.githubusercontent.com/mekanoe/arch-setup/main/fresh.sh > /mnt/.remove-before-flight/fresh.sh
mount | grep '/mnt type' | cut -d' ' -f1 > /mnt/.remove-before-flight/rootfs

echo ">> Chrooting into new system. Run \`bash /.remove-before-flight/fresh.sh\` when you're ready."
arch-chroot /mnt