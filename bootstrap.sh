set -e
set -o pipefail
mount | grep -e '/mnt type' | cut -d' ' -f1 > /mnt/.remove-before-flight/rootfs
mount | grep -e '/mnt/boot type'
set +o pipefail

mkdir -p /mnt/etc/mkinitcpio.d > /dev/null 2>&1
mkdir -p /etc/mkinitcpio.d > /dev/null 2>&1
cat <<EOF > /mnt/etc/mkinitcpio.d/linux-zen.preset
# mkinitcpio preset file for the 'linux-zen' package

#ALL_config="/etc/mkinitcpio.conf"
ALL_kver="/boot/vmlinuz-linux-zen"
ALL_microcode=(/boot/*-ucode.img)

PRESETS=('default' 'fallback')

#default_config="/etc/mkinitcpio.conf"
default_image="/boot/initramfs-linux-zen.img"
#default_uki="/efi/EFI/Linux/arch-linux-zen.efi"
#default_options="--splash /usr/share/systemd/bootctl/splash-arch.bmp"

#fallback_config="/etc/mkinitcpio.conf"
fallback_image="/boot/initramfs-linux-zen-fallback.img"
#fallback_uki="/efi/EFI/Linux/arch-linux-zen-fallback.efi"
fallback_options="-S autodetect"
EOF
cp /mnt/etc/mkinitcpio.d/linux-zen.preset /etc/mkinitcpio.d/linux-zen.preset

ucode=$(cat /proc/cpuinfo | grep -qe GenuineIntel > /dev/null && echo intel-ucode || echo amd-ucode)
pacstrap -K /mnt linux-zen linux-zen-headers linux-firmware $ucode zsh git base-devel

mkdir /mnt/.remove-before-flight > /dev/null 2>&1
curl -sSL https://raw.githack.com/mekanoe/arch-setup/main/fresh.sh > /mnt/.remove-before-flight/fresh.sh

echo ">> Chrooting into new system. Run \`bash /.remove-before-flight/fresh.sh\` when you're ready."
arch-chroot /mnt