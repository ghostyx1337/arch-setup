#!/usr/bin/env bash

set -e

echo "=== Updating Arch Linux System ==="
sudo pacman -Syu --noconfirm
# Désactiver la génération des packages de debug pour accélérer yay
sudo sed -i 's/OPTIONS=(/OPTIONS=(!debug /' /etc/makepkg.conf
sudo sed -i "s/#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j\$(nproc)\"/" /etc/makepkg.conf
sudo sed -i 's/#BUILDDIR=\/tmp\/makepkg/BUILDDIR=\/tmp\/makepkg/' /etc/makepkg.conf

# ----------------------------------------------------------------------
# 1. Base Development, Security & Core Desktop Packages
# ----------------------------------------------------------------------
OFFICIAL_PACKAGES=(
    # Core Desktop (KDE Plasma - closest base for Windows 11 layout)
    "plasma-desktop"
    "plasma-workspace"
    "dolphin"                 # File manager (similar to File Explorer)
    "konsole"                 # Terminal
    "kscreen"                 # Display manager
    "plasma-nm"                # Network manager widget
    "plasma-pa"                # Audio widget
    "sddm"                    # Display manager (Login screen)
    
    # Development & System
    "git"
    "curl"
    "wget"
    "docker"
    "docker-compose"
    "nodejs"
    "npm"
    "python"
    "python-pip"
    "rust"
    "go"
    "dbeaver"
    "neovim"
    "htop"
    "fastfetch"

    # Cybersecurity Tools
    "nmap"
    "wireshark-qt"
    "tcpdump"
    "masscan"
    "zaproxy"
    "netcat"
    "strace"
    "radare2"
    "ghidra"
    "hydra"

    # Browsers
    "firefox"
    "librewolf"
)

echo "=== Installing Official Packages & KDE Plasma Base ==="
sudo pacman -S --needed --noconfirm "${OFFICIAL_PACKAGES[@]}"

# ----------------------------------------------------------------------
# 2. Install AUR Helper (yay)
# ----------------------------------------------------------------------
if ! command -v yay &> /dev/null; then
    echo "=== Installing yay AUR Helper ==="
    sudo pacman -S --needed --noconfirm base-devel git
    BUILD_DIR=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$BUILD_DIR/yay"
    cd "$BUILD_DIR/yay"
    makepkg -si --noconfirm
    cd - > /dev/null
    rm -rf "$BUILD_DIR"
fi

# ----------------------------------------------------------------------
# 3. Install AUR Packages & Windows 11 Theme Packages
# ----------------------------------------------------------------------
AUR_PACKAGES=(
    # General Applications
    "visual-studio-code-bin"
    "spotify"
    "discord"
    "burpsuite"
    "metasploit"
    "konsave"

    # Windows 11 GUI Theme Repos / Packages (via AUR)
    "plasma5-theme-expanse-git"     # Windows 11 style global theme elements
    "fluent-gtk-theme-git"          # Windows 11 Fluent Design GTK theme
    "fluent-icon-theme-git"         # Windows 11 style icons
    "fluent-cursor-theme-git"       # Windows 11 style mouse cursors
)

if [ ${#AUR_PACKAGES[@]} -gt 0 ]; then
    echo "=== Installing AUR Apps and Windows 11 Theme Packages ==="
    yay -S --needed --noconfirm "${AUR_PACKAGES[@]}"
fi

# ----------------------------------------------------------------------
# 4. Enable System Services
# ----------------------------------------------------------------------
echo "=== Enabling System Services ==="

# Enable Login Manager
sudo systemctl enable sddm.service

# Enable Docker
if systemctl list-unit-files | grep -q docker.service; then
    sudo systemctl enable --now docker.service
    sudo usermod -aG docker "$USER"
fi

# Enable Wireshark non-root access
if getent group wireshark > /dev/null; then
    sudo usermod -aG wireshark "$USER"
fi

# ----------------------------------------------------------------------
# 5. Automated Windows 11 GUI Configuration (KDE Plasma)
# ----------------------------------------------------------------------
echo "=== Applying Windows 11 Theme Settings ==="

# Set Icons to Fluent
kwriteconfig5 --file kdeglobals --group Icons --key Theme "Fluent"

# Set Cursor Theme
kwriteconfig5 --file kcminputrc --group Mouse --key cursorTheme "Fluent-cursors"

# Set GTK Theme (for apps like Firefox/VS Code)
mkdir -p ~/.config/gtk-3.0 ~/.config/gtk-4.0
cat <<EOF > ~/.config/gtk-3.0/settings.ini
[Settings]
gtk-theme-name=Fluent-Dark
gtk-icon-theme-name=Fluent
gtk-cursor-theme-name=Fluent-cursors
EOF

cat <<EOF > ~/.config/gtk-4.0/settings.ini
[Settings]
gtk-theme-name=Fluent-Dark
gtk-icon-theme-name=Fluent
gtk-cursor-theme-name=Fluent-cursors
EOF

# Enable Login Manager
sudo systemctl enable sddm.service

# Enable Docker
if systemctl list-unit-files | grep -q docker.service; then
    sudo systemctl enable --now docker.service
    sudo usermod -aG docker "$USER"
fi

# Enable Wireshark non-root access
if getent group wireshark > /dev/null; then
    sudo usermod -aG wireshark "$USER"
fi

konsave -i /path/to/Win11Theme.knsv
konsave -a Win11Theme

echo "=== Setup Complete! Reboot your system to load the changes. ==="
