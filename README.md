# Arch Installer

## Overview

This installer automates a complete Arch Linux setup with a custom user environment and software. The process is divided into three phases:

- **Phase 0:** Base installation from the Arch Live USB (partitioning, base system, and initial setup)
- **Phase 1:** System configuration inside the chroot environment (locale, users, bootloader, etc.)
- **Phase 2:** User environment setup after the first boot (dotfiles, user packages, theming, etc.)

---

## Prerequisites

- Arch Linux Live USB
- Internet connection
- Familiarity with basic Linux commands

---

## Usage

1. **Boot from the Arch Linux Live USB.**

2. **Connect to the internet.**

   - For Wi-Fi: `iwctl` or `wifi-menu` (if available)
   - For Ethernet: Should be automatic

3. **Clone this repository and enter the folder:**

   ```bash
   git clone https://github.com/YOUR_USERNAME/archsetup.git
   cd archsetup
   chmod +x *.sh user-setup/*.sh
   ```

4. **Start the installation:**

   ```bash
   ./install.sh
   ```

5. **Follow on-screen prompts for each phase.**

---

## Customization

- Edit `packages.txt` and `services.txt` to add or remove software and services.
- Adjust scripts in `user-setup/` for user-specific configuration.
- Review and modify any configuration files as needed for your setup.
- To change shell aliases, edit `zsh_aliases`.

---

## Troubleshooting

- **Script fails to run:** Ensure all scripts are executable (`chmod +x *.sh user-setup/*.sh`).
- **Network issues:** Double-check your connection before running the installer.
- **Partitioning errors:** Make sure you have backed up your data and selected the correct drives.
- For more help, check the logs or script output.

---

## Notes

- **Backup your data!** This script will format drives and make system changes.
- Tested with the latest Arch ISO as of [date].

---

# Folder Structure

- `install.sh` — Main entry point for the installer
- `README.md` — Documentation
- `scripts/packages.txt` — List of packages to install
- `scripts/services.txt` — List of services to enable
- `scripts/` — Contains all phase scripts and helper scripts:
  - `0-preinstall.sh`
  - `1-chrootsetup.sh`
  - `2-postinstall.sh`

# Setup

Move all phase scripts into the `scripts/` folder for clarity. Update `install.sh` to reference them from `scripts/`.

# Example Structure

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

# Next Steps

- Move the phase scripts into `scripts/`.
- Update `install.sh` to call them from the new location.
- Place any future helper scripts in `scripts/` as well.

## License

[MIT](LICENSE)
