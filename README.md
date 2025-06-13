# Arch Installer

## What You Need

- A computer you are willing to erase and set up from scratch (all data will be lost).
- A USB stick (at least 2GB) to create an Arch Linux Live USB.
- Another computer to download and create the USB if needed.
- Internet access during installation.

---

## Step-by-Step Installation

1. **Create an Arch Linux Live USB**
   - Download the Arch Linux ISO from [archlinux.org](https://archlinux.org/download/).
   - Use a tool like [balenaEtcher](https://www.balena.io/etcher/) or [Rufus](https://rufus.ie/) to write the ISO to your USB stick.
2. **Boot from the USB**
   - Insert the USB stick into your computer and restart.
   - Enter your BIOS/UEFI settings (usually by pressing F2, F10, F12, or DEL right after turning on your computer).
   - Set the USB stick as the first boot device and save changes.
   - Your computer should now boot into the Arch Linux installer.
3. **Connect to the internet.**
   - For Wi-Fi: Type `iwctl` and follow the prompts, or use `wifi-menu` if available.
   - For Ethernet: It should connect automatically.
4. **Open a terminal.**
   - You should already be at a terminal prompt after booting. If not, press `Ctrl+Alt+F2` to open one.

---

## Requirements & Partitioning

- **WARNING: This process will erase all data on the selected disk. Make sure to back up your files first!**
- You will need to create two partitions on your disk:
  1. **EFI partition** (about 512MB, type “EFI System”)
  2. **Root partition** (at least 10GB, type “Linux filesystem”)
- The installer scripts will guide you through partitioning and after will handle formatting the required partitions automatically.
- Example for `/dev/nvme1n1`:
  - `/dev/nvme1n1p1` — EFI
  - `/dev/nvme1n1p2` — Root
- The installer will format the EFI partition as FAT32 and the root partition as BTRFS. You do not need to format them yourself, just create the partitions.

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

1. **Install git (required to clone this repo):**
   - Type:
     ```sh
     pacman -Sy git
     ```
   - If you see a prompt about proceeding, type `y` and press Enter.
2. **Clone this repository and make scripts executable:**
   - Type:
     ```sh
     git clone https://github.com/sebastiancostiug/arch_install
     cd arch_install
     chmod +x *.sh scripts/*.sh
     ```
3. **Start the installer:**
   - Type:
     ```sh
     ./install.sh
     ```
   - Follow the on-screen prompts. You will be asked for your username, disk, and hostname.
   - When asked for a disk, type `/dev/` folowed by the name exactly as shown in the list (e.g., `/dev/sda` or `/dev/nvme0n1`).

---

## After Installation: Final User Setup

After the system reboots, log in with the username you created.

1. **Open the Terminal application.**
   - You can find it in the application menu or by pressing `Ctrl+Alt+T`.
2. **Run the final setup script:**
   - Type:
     ```sh
     ~/Downloads/2-postinstall.sh
     ```
   - Press Enter and follow any prompts.

This will:

- Set up your dotfiles and shell
- Install AUR and Flatpak apps
- Finalize your user environment

After setup is complete, the script will automatically delete itself and the dotfiles from your Downloads folder to keep things tidy.

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

## Need Help?

If you get stuck, search for the error message online or ask for help on the [Arch Linux Forums](https://bbs.archlinux.org/) or [Reddit r/archlinux](https://www.reddit.com/r/archlinux/).

Don’t be afraid to ask questions—everyone was a beginner once!

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
