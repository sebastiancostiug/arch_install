#!/usr/bin/env bash
# install.sh - Minimal Arch Install Automation
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
log() { echo -e "${YELLOW}[LOG]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }

if [[ $EUID -ne 0 ]]; then echo "Run as root."; exit 1; fi

# === Interactive prompts for all variables ===
read -rp "Enter username for new user: " USERNAME
while [[ -z "$USERNAME" ]]; do read -rp "Username cannot be empty. Enter username: " USERNAME; done

echo "Available disks:"
lsblk -d -o NAME,SIZE,MODEL,TYPE | grep disk
read -rp "Enter target disk (e.g. /dev/nvme1n1): " DISK
while [[ -z "$DISK" || ! -b "$DISK" ]]; do read -rp "Disk not found. Enter valid disk (e.g. /dev/nvme1n1): " DISK; done

read -rp "Enter hostname (default: arch): " HOSTNAME
HOSTNAME="${HOSTNAME:-arch}"

log "Starting Phase 0: Pre-install (run from Live USB)"
./scripts/0-preinstall.sh "$DISK"

log "Starting Phase 1: Chroot Setup (system configuration)"
echo "[+] Entering chroot for system configuration..."
arch-chroot /mnt /root/arch_install/scripts/1-chrootsetup.sh "$USERNAME" "$HOSTNAME"

log "Starting Phase 2: Post-install user setup (run as new user)"
cp -r ./user-setup /mnt/home/"$USERNAME"/
arch-chroot /mnt bash -c "cd /home/$USERNAME/user-setup && sudo -u $USERNAME ../scripts/2-postinstall.sh"

success "Installation complete. You may now reboot."
echo "[!] Reminder: Enable any optional manual tweaks post-reboot."
