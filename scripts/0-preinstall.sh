#!/usr/bin/env bash
# Phase 0 - Base Install: Run from Arch Live USB
set -euo pipefail

# === CONFIGURABLE VARIABLES ===
DISK="${1:-}" # e.g. /dev/sda or /dev/nvme0n1
DRY_RUN="${DRY_RUN:-false}"
LOGFILE="/tmp/arch_preinstall.log"

# === COLOR OUTPUT ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() { echo -e "${YELLOW}[LOG]${NC} $1" | tee -a "$LOGFILE"; }
err() { echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOGFILE" >&2; }
success() { echo -e "${GREEN}[OK]${NC} $1" | tee -a "$LOGFILE"; }

# === CHECKS ===
if [[ $EUID -ne 0 ]]; then err "Run as root."; exit 1; fi
for cmd in cfdisk mkfs.fat mkfs.btrfs pacstrap genfstab lsblk; do
  command -v $cmd >/dev/null 2>&1 || { err "$cmd is required."; exit 1; }
done
if [[ -z "$DISK" ]]; then
  echo "Usage: $0 /dev/sdX or /dev/nvmeXn1"
  exit 1
fi

log "Disk layout before partitioning:"; lsblk "$DISK"
read -p "${YELLOW}WARNING: This will erase all data on $DISK. Continue? (y/N)${NC} " confirm
[[ $confirm == [yY] ]] || { err "Aborted by user."; exit 1; }

log "Setting keyboard layout and connecting to internet..."
loadkeys us
if ! ping -c3 archlinux.org; then err "No internet connectivity."; exit 1; fi

log "Partitioning disk $DISK..."
cfdisk "$DISK"

log "Disk layout after partitioning:"; lsblk "$DISK"

# Verify partitions exist
if [[ ! -b "${DISK}p1" || ! -b "${DISK}p2" ]]; then err "Partitions not found. Aborting."; exit 1; fi

log "Formatting partitions..."
mkfs.fat -F32 "${DISK}p1"
mkfs.btrfs -f "${DISK}p2"

log "Mounting partitions..."
mount "${DISK}p2" /mnt
mkdir -p /mnt/boot
mount "${DISK}p1" /mnt/boot

log "Installing base system..."
pacstrap /mnt base linux linux-firmware btrfs-progs nano sudo

log "Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

log "Copying setup scripts to new system..."
cp -r . /mnt/root/arch_setup
chmod +x /mnt/root/arch_setup/*.sh

success "Phase 0 complete. Ready for chroot."
