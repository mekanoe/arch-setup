set -e

run() {
  echo ">> Running: $@"
  "$@"
}

# =>> BASICS =>>
install_basic_packages() {
  run sudo pacman -Syyu --noconfirm --needed git base-devel

  mkdir -p /tmp/yay
  cd /tmp/yay
  git clone https://aur.archlinux.org/yay-bin.git
  cd yay-bin
  makepkg -si --noconfirm
  cd ~
  rm -rf /tmp/yay

  yay -Y --gendb
  yay -Syu \
    --devel \
    --combinedupgrade \
    --save

  yay -S --noconfirm oh-my-zsh-git
}

# =>> ESSENTIALS =>>
install_essentials() {
  run yay -Syu --noconfirm \
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
    neofetch \
    podman \
    flatpak \
    tlp \
    preload \
    visual-studio-code-bin \
    kitty \
    kitty-terminfo \
    tailscale
}

nv_desktop() {
  run yay -Syu --noconfirm \
    nvidia-dkms \
    nvidia-settings
}

nv_laptop() {
  nv_desktop

  run yay -R --noconfirm \
    tlp
  run yay -Syu --noconfirm \
    power-profiles-daemon \
    gdm-prime \
    optimus-manager
}

# =>> FLATPAKS =>>
install_flatpaks() {
  run sudo flatpak repo add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  run sudo flatpak install -y flathub com.spotify.Client
  run sudo flatpak install -y flathub com.discordapp.Discord
  run sudo flatpak install -y flathub com.mattjakeman.ExtensionManager
  run sudo flatpak install -y flathub org.mozilla.firefox
  run sudo flatpak install -y flathub org.gtk.Gtk3theme.adw-gtk3-dark
  run sudo flatpak install -y flathub org.gtk.Gtk3theme.adw-gtk3
  run sudo flatpak install -y flathub com.github.tchx84.Flatseal
}

configure_flatpak() {
  run sudo flatpak override --filesystem=~/.local/share/themes
  run sudo flatpak override --filesystem=~/.config/discord com.discordapp.Discord
}

# =>> THEMES =>>
setup_crycord() {
  mkdir -p ~/.config/discord
  echo '@import "https://raw.githack.com/mekanoe/mekadnome/mekadnome.css";' > ~/.config/discord/mekadnome.css
  crycord -c ~/.config/discord/mekadnome.css -p enable_css,enable_https,enable_web_tools
}

# =>> INTERNAL UTILS =>>
fn_exists() { declare -F "$1" > /dev/null; }

# =>> MAIN =>>
main() {
  fn_exists $1 && { "$1"; exit 0; } || echo "Running normal sync..."

  install_basic_packages
  install_essentials
  install_flatpaks
  configure_flatpak
  setup_crycord

  echo "Run \`rm -rf /.remove-before-flight\`."
}

main "$@"