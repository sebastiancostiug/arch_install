# Arch Installer

## Overview

This installer sets up a **minimal, modern Arch Linux system** with:

- GNOME desktop environment (core GNOME apps and tweaks)
- Gaming support (Steam, Vulkan, AMD drivers, Flatpak games)
- Developer tools (base-devel, git, docker, nodejs, php, etc.)
- BTRFS root filesystem and GRUB bootloader
- Useful utilities (htop, mc, rsync, nano, etc.)
- Optional AUR and Flatpak apps for productivity and customization

**Result:** A clean, fast, and ready-to-use Arch Linux desktop for daily use, gaming, and development.

---

## Requirements & Partitioning

- **Requires:** Arch Linux Live USB, internet connection, basic Linux knowledge
- **Disk layout:**

  - The installer expects **2 partitions** on your target disk:
    - **EFI partition:** ~512MB, type EFI System
    - **Root partition:** Rest of disk, type Linux filesystem
  - Example for `/dev/nvme1n1`:

    - `/dev/nvme1n1p1` — EFI
    - `/dev/nvme1n1p2` — Root

  - They will be formatted by the script as FAT32 the EFI partition and BTRFS the root partition (you don't need to format them just provide the 2 partitions in you partition setup)

  - Any other partitions can be created and handled separately but the installer needs these two

---

## Installation Phases

- **Phase 0: Base Install**
  - Run from the Arch Live USB
  - Partition, format, and mount disks
  - Install base system and copy setup scripts
- **Phase 1: System Configuration**
  - Run inside chroot
  - Set timezone, locale, hostname, users, sudo, bootloader, and install all packages
  - Enable system services
- **Phase 2: User Environment Setup**
  - Run as the new user after first boot
  - Set up dotfiles, shell, AUR/Flatpak apps, and user environment

---

## Getting Started

1. **Boot from the Arch Linux Live USB.**
2. **Connect to the internet.**
   - For Wi-Fi: `iwctl` or `wifi-menu` (if available)
   - For Ethernet: Should be automatic
3. **Install git (required to clone this repo):**
   ```bash
   pacman -Sy git
   ```
4. **Clone this repository and make scripts executable:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/archsetup.git
   cd archsetup
   chmod +x scripts/*.sh
   ```
5. **Start the installer:**
   ```bash
   ./install.sh
   ```
6. **Follow on-screen prompts for each phase.**

---

## After Installation: Final User Setup

After the system reboots, log in as your new user and run the following to complete your user environment setup:

```zsh
~/Downloads/2-postinstall.sh
```

This will:

- Set up your dotfiles and shell
- Install AUR and Flatpak apps
- Finalize your user environment

You can delete `~/Downloads/2-postinstall.sh` after setup is complete.

---

## Customization

- Edit `scripts/packages.txt` and `scripts/services.txt` to add or remove software and services.
- Adjust scripts in `user-setup/` for user-specific configuration.
- Review and modify any configuration files as needed for your setup.
- To change shell aliases, edit `dotfiles/zsh_aliases`.

---

## Troubleshooting

- **Script fails to run:** Ensure all scripts are executable (`chmod +x scripts/*.sh`).
- **Network issues:** Double-check your connection before running the installer.
- **Partitioning errors:** Make sure you have backed up your data and selected the correct drives.
- For more help, check the logs or script output.

---

## Notes

- **Backup your data!** This script will format drives and make system changes.
- Tested with the latest Arch ISO as of June 2025.

---

## Folder Structure

- `install.sh` — Main entry point for the installer
- `README.md` — Documentation
- `scripts/packages.txt` — List of packages to install
- `scripts/services.txt` — List of services to enable
- `scripts/` — Contains all phase scripts and helper scripts:
  - `0-preinstall.sh`
  - `1-chrootsetup.sh`
  - `2-postinstall.sh`

## Example Structure

```
arch 2.0/
├── install.sh
├── README.md
├── scripts/packages.txt
├── scripts/services.txt
└── scripts/
    ├── 0-preinstall.sh
    ├── 1-chrootsetup.sh
    └── 2-postinstall.sh
```

## License

[MIT](LICENSE)
