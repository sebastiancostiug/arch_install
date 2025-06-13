#!/usr/bin/env bash
# Phase 2 - User Setup (Run as regular user inside chroot)
set -euo pipefail

LOGFILE="/tmp/arch_postinstall.log"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
log() { echo -e "${YELLOW}[LOG]${NC} $1" | tee -a "$LOGFILE"; }
err() { echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOGFILE" >&2; }
success() { echo -e "${GREEN}[OK]${NC} $1" | tee -a "$LOGFILE"; }

# === Set default shell to zsh ===
log "Setting default shell to zsh..."
chsh -s $(which zsh)

# === Oh My Zsh and plugins ===
log "Installing Oh My Zsh and plugins..."
export ZSH="$HOME/.oh-my-zsh"
rm -rf "$ZSH"
RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended
ZSH_CUSTOM="$ZSH/custom"
for repo in \
  "https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k" \
  "https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions" \
  "https://github.com/z-shell/F-Sy-H.git $ZSH_CUSTOM/plugins/F-Sy-H"
do
  set -- $repo; if [[ ! -d "$2" ]]; then git clone "$1" "$2"; fi
done

# === Dotfiles ===
DOTFILES_DIR="$HOME/Downloads/dotfiles"
log "Setting up dotfiles..."
for f in "$DOTFILES_DIR/.zshrc"; do
  [[ -e "$HOME/$(basename $f)" ]] && mv "$HOME/$(basename $f)" "$HOME/$(basename $f).bak"
  ln -sf "$f" "$HOME/$(basename $f)"
done
mkdir -p "$HOME/.config"
cp -rn "$DOTFILES_DIR/.config/"* "$HOME/.config/"

# === Flatpak permissions ===
if command -v flatpak >/dev/null; then
  log "Setting Flatpak permissions..."
  flatpak override --user --filesystem=xdg-config/gtk-4.0 || true
  sudo flatpak override --filesystem=$HOME/.themes || true
  sudo flatpak override --filesystem=$HOME/.icons || true
fi

# === Flatpak apps ===
if command -v flatpak >/dev/null; then
  log "Installing Flatpak apps..."
  FLATPAK_APPS=(
    com.spotify.Client
    com.heroicgameslauncher.hgl
    com.github.tchx84.Flatseal
    com.mattjakeman.ExtensionManager
    net.davidotek.pupgui2
    com.bitwarden.desktop
    com.github.unrud.VideoDownloader
    org.mozilla.Thunderbird
    org.torproject.torbrowser-launcher
    com.rtosta.zapzap
    fr.handbrake.ghb
    org.gnome.TextEditor
    org.gnome.Weather
    org.gnome.clocks
    io.github.celluloid_player.Celluloid
    org.gnome.Logs
    org.gnome.Brasero
  )
  for app in "${FLATPAK_APPS[@]}"; do
    flatpak install -y flathub "$app" || err "Flatpak install failed: $app"
  done
fi

# === AUR packages ===
log "Installing AUR packages..."
AUR_PKGS=(visual-studio-code-bin grub-customizer vesktop-bin cursor-bin)
mkdir -p "$HOME/AUR" && cd "$HOME/AUR"
for pkg in "${AUR_PKGS[@]}"; do
  [[ -d $pkg ]] && rm -rf $pkg
  git clone "https://aur.archlinux.org/$pkg.git"
  cd $pkg && makepkg -si --noconfirm || err "AUR install failed: $pkg"; cd ..
done

# === Git config (prompt for name/email) ===
read -rp "Enter your Git user name: " GIT_NAME
while [[ -z "$GIT_NAME" ]]; do read -rp "Git user name cannot be empty. Enter your Git user name: " GIT_NAME; done
read -rp "Enter your Git email: " GIT_EMAIL
while [[ -z "$GIT_EMAIL" ]]; do read -rp "Git email cannot be empty. Enter your Git email: " GIT_EMAIL; done
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

# === SSH permissions ===
if [[ -d ~/.ssh ]]; then
  chmod 700 ~/.ssh
  [[ -f ~/.ssh/id_ed25519 ]] && chmod 600 ~/.ssh/id_ed25519
  [[ -f ~/.ssh/id_ed25519.pub ]] && chmod 644 ~/.ssh/id_ed25519.pub
fi

success "User setup complete."

# ===Cleanup: remove this script and dotfiles ===
SCRIPT_PATH="$HOME/Downloads/2-postinstall.sh"
DOTFILES_PATH="$HOME/Downloads/dotfiles"
if [[ -d "$DOTFILES_PATH" ]]; then
  rm -rf "$DOTFILES_PATH"
  log "Removed $DOTFILES_PATH"
fi
if [[ -f "$SCRIPT_PATH" ]]; then
  rm -f "$SCRIPT_PATH"
  log "Removed $SCRIPT_PATH"
fi

