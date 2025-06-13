#!/usr/bin/env bash
# Phase 1 - System Configuration (Run inside chroot)
set -euo pipefail

# === CONFIGURABLE VARIABLES ===
USERNAME="${1:-}"
HOSTNAME="${2:-arch}"
TIMEZONE="${TIMEZONE:-Europe/Bucharest}"
LOCALE="${LOCALE:-en_US.UTF-8}"
LOGFILE="/tmp/arch_chrootsetup.log"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
log() { echo -e "${YELLOW}[LOG]${NC} $1" | tee -a "$LOGFILE"; }
err() { echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOGFILE" >&2; }
success() { echo -e "${GREEN}[OK]${NC} $1" | tee -a "$LOGFILE"; }

if [[ $EUID -ne 0 ]]; then err "Run as root."; exit 1; fi
if [[ -z "$USERNAME" ]]; then
  echo "Usage: $0 username [hostname]"
  exit 1
fi

log "Setting time, locale, hostname..."
ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
hwclock --systohc
echo "$LOCALE UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=$LOCALE" > /etc/locale.conf
echo "$HOSTNAME" > /etc/hostname
cat > /etc/hosts <<EOF
127.0.0.1 localhost
::1       localhost
127.0.1.1 $HOSTNAME.localdomain $HOSTNAME
EOF

log "Enabling repos and updating system..."
if ! grep -q '\[multilib\]' /etc/pacman.conf; then
  echo -e '\n[multilib]\nInclude = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf
fi
if ! grep -q '\[lizardbyte\]' /etc/pacman.conf; then
  echo -e '\n[lizardbyte]\nSigLevel = Optional TrustAll\nServer = https://github.com/LizardByte/pacman-repo/releases/latest/download' >> /etc/pacman.conf
fi

pacman -Sy --noconfirm

log "Installing packages from packages.txt..."
pacman -Syu --noconfirm $(grep -vE '^#' /root/arch_setup/scripts/packages.txt) | tee -a "$LOGFILE"

log "Setting root password..."
passwd

log "Creating user $USERNAME..."
useradd -mG wheel "$USERNAME"
passwd "$USERNAME"

log "Editing sudoers to allow wheel group sudo access..."
cp /etc/sudoers /etc/sudoers.bak
sed -i '/%wheel ALL=(ALL) ALL/s/^# //' /etc/sudoers

log "Installing and configuring GRUB bootloader..."
pacman -S --noconfirm grub efibootmgr os-prober
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

log "Enabling system services from services.txt..."
while read -r svc; do
  systemctl enable --now "$svc"
done < /root/arch_setup/scripts/services.txt

success "Chroot setup complete."
