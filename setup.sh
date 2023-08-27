set -ex

run() {
  echo ">> Running: $@"
  "$@"
}

# BASICS ======================>>
install_basic_packages() {
  run pacman -Syyu --noconfirm --needed git base-devel

  mkdir -p /tmp/yay
  cd /tmp/yay
  git clone https://aur.archlinux.org/yay-bin.git
  cd yay-bin
  makepkg -si
  cd ~
  rm -rf /tmp/yay

  yay -Y --gendb
  yay -Syu \
    --devel \
    --combinedupgrade \
    --save

  yay -S --noconfirm oh-my-zsh-git
}

# FLATPAKS ====================>>
install_flatpaks() {
  run flatpak repo add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  run flatpak install -y flathub com.spotify.Client
  run flatpak install -y flathub com.discordapp.Discord
  run flatpak install -y flathub com.mattjakeman.ExtensionManager
  run flatpak install -y flathub org.mozilla.firefox
  run flatpak install -y flathub org.gtk.Gtk3theme.adw-gtk3-dark
  run flatpak install -y flathub org.gtk.Gtk3theme.adw-gtk3
  run flatpak install -y flathub com.github.tchx84.Flatseal
}

configure_flatpak() {
  run flatpak override --filesystem=~/.local/share/themes
  run flatpak override --filesystem=~/.config/discord com.discordapp.Discord
}

# ESSENTIALS =======================>>
install_essentials() {
  yay -S --noconfirm \
    bind \
    cloudflared \
    github-cli \
    adw-gtk-theme \
    adw-gtk3-git \
    gradience \
    nodejs \
    mesa-utils \
    crycord \
    python-pywalfox \
    pywal \
    neofetch \
    podman \
    flatpak \ 
    power-profiles-daemon \
    preload \
    visual-studio-code-bin \
    kitty \
    kitty-terminfo
}

main() {
  install_basic_packages
  install_essentials
  install_flatpaks
  configure_flatpak
}

main "$@"