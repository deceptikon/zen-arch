# 🚀 My Arch Linux Dotfiles

A modular, automated dotfiles repository for an Arch Linux + Sway/Wayland setup. It includes a custom bash script that automatically intelligently maps, symlinks, and tracks configuration files and user media.

## ✨ Features

- **Window Manager & Panel:** Sway + Waybar configured for optimal workflow.
- **Smart Setup Script:** Features a custom setup parser that handles strict dependency checking, package name resolution (e.g., `Telegram:telegram-desktop`), and dynamic symlinking.
- **XDG Compliant:** Logs are strictly routed to `~/.local/state`, keeping the config directory and git repository clean.
- **Dynamic Namespaces:** 
  - `dot_*` folders are automatically processed and symlinked as hidden files/folders (e.g., `dot_config` -> `~/.config`).
  - `home_*` folders map directly to the user's home directory (e.g., `home_Media_wallpapers` -> `~/Media/wallpapers`).

## ⚙️ Installation

1. Clone the repository into your home directory:
   ```bash
   git clone https://github.com/deceptikon/zen-arch.git ~/.dotfiles
   cd ~/.dotfiles
```

    Run the interactive setup script:

    `./setup.sh install`

    The script will perform a system integrity check, list exactly which packages need to be installed via pacman/paru, and selectively symlink all configurations.

📂 Repository Structure

    setup.sh - The brain of the repository. Handles dependency checks and symlinks.
    dot_config/ - Contains configurations for Sway, Waybar, Rofi, WezTerm, Dunst, etc.
    dot_zshrc / dot_zshenv - Zsh shell configs.
    home_Media_wallpapers/ - Backgrounds synced seamlessly to ~/Media/wallpapers.

🛠️ Management

To completely safely unlink the dotfiles and revert back to your default setup, run:

`./setup.sh uninstall`


