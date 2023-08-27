set -e

run() {
  echo ">> Running: $@"
  "$@"
}

# =>> BASICS =>>
install_basic_packages() {
  run sudo pacman -Syyu --noconfirm --needed git base-devel reflector

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

  enable_reflector
}

enable_reflector() {
    sudo tee /etc/xdg/reflector/reflector.conf <<EOF
--save /etc/pacman.d/mirrorlist
--latest 25
--sort rate
--protocol https
--country US
--fastest 10
EOF

  sudo rm -f /usr/lib/systemd/system/reflector.timer
  sudo tee /etc/systemd/system/reflector.timer <<EOF
[Unit]
Description=Refresh Pacman mirrorlist daily with Reflector.

[Timer]
OnCalendar=daily
Persistent=true
AccuracySec=1us
RandomizedDelaySec=12h

[Install]
WantedBy=timers.target
EOF

  sudo systemctl daemon-reload
  sudo systemctl enable reflector.service
  sudo systemctl enable reflector.timer

  run sudo reflector @/etc/xdg/reflector/reflector.conf
}

install_configs() {
  mkdir -p /tmp/arch-setup
  cd /tmp/arch-setup
  git clone https://github.com/mekanoe/arch-setup.git .

  # ZSH
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-syntax-highlighting  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting 
  git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
  cp configs/.zshrc ~/.zshrc

  # Kitty
  mkdir -p ~/.config/kitty
  cp configs/kitty.conf ~/.config/kitty/kitty.conf
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
    tailscale \
    ttf-fira-code \
    ttf-atkinson-hyperlegible \
    gnome \
    gnome-tweaks \
    gnome-shell-extensions

  run sudo systemctl enable gdm
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
  run sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
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
  run sudo flatpak override --filesystem=xdg-config/gtk-3.0
  run sudo flatpak override --filesystem=xdg-config/gtk-4.0
}

# =>> THEMES =>>
setup_crycord() {
  mkdir -p ~/.config/discord > /dev/null 2>&1
  echo '@import "https://raw.githack.com/mekanoe/mekadnome/mekadnome.css";' > ~/.config/discord/mekadnome.css
  crycord -c ~/.config/discord/mekadnome.css -p enable_css,enable_https,enable_web_tools
}

# =>> INTERNAL UTILS =>>
fn_exists() { declare -F "$1" > /dev/null; }

help() {
  echo <<EOF
Usage: $0 [option]

(no args): full install script. likely non-destructive.

extra: 
  nv-desktop: NVIDIA desktop install
  nv-laptop: NVIDIA laptop install
  help: this message
  steam: install steam w/ extras

EOF
}

# =>> MAIN =>>
main() {
  fn_exists $1 && { "$1"; exit 0; } || echo "Running normal sync..."

  install_basic_packages
  install_essentials
  install_flatpaks
  configure_flatpak
  setup_crycord
  install_configs

  test -d /.remove-before-flight && echo "Run \`rm -rf /.remove-before-flight\` if needed."
}

main "$@"