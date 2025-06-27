#!/bin/bash

# EndeavourOS initial setup

# Colors for output in terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color


# check is command successfull
check_success() {
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: $1 failed${NC}"
    else
        echo -e "${GREEN}$1 successful${NC}"
    fi
    sleep 5
}


# log current process
log_command_info() {
    echo -e "${YELLOW}$1${NC}"
}


# check if script executed as root
if [ "$(id -u)" -ne 0 ]; then
    log_command_info "You are not root :("
    exit 1
fi


# updating system
log_command_info "Updating system..."
pacman -Syu --noconfirm
check_success "System update"


# install AMD video driver
log_command_info "Installing AMD video drivers..."
pacman -S --noconfirm --needed mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon libva-mesa-driver libva-utils
check_success "AMD driver installation"


# install mandatory packages
log_command_info "Installing mandatory packages..."
pacman -S --noconfirm --needed fastfetch flatpak micro telegram-desktop btop alacritty steam openrgb vscode obs-studio
check_success "Mandatory packages installation"


# install packages from flatpak
log_command_info "Installing flatpak packages..."
flatpak install flathub com.discordapp.Discord
check_success "Flatpak packages installation"


# configure alacritty config
log_command_info "Configuring alacritty config..."
mkdir -p /home/$(logname)/.config/alacritty
# STARTOF: cloning themes for alacritty
mkdir -p /home/$(logname)/.config/alacritty/themes
git clone https://github.com/alacritty/alacritty-theme /home/$(logname)/.config/alacritty/themes
# ENDOF: cloning themes for alacritty
cat > /home/$(logname)/.config/alacritty/alacritty.toml <<EOF
[general]
import = [
	"~/.config/alacritty/themes/themes/catppuccin_mocha.toml"
]

[window]
opacity = 0.9
dimensions = { lines = 50, columns = 150 }
EOF
chown -R $(logname):$(logname) /home/$(logname)/.config/alacritty
check_success "Alacritty configured"


# disable password entering for sudo
no_sudo_conf="$(logname) ALL=(ALL:ALL) NOPASSWD:ALL"
if ! grep -qF "$no_sudo_conf" /etc/sudoers; then
    echo -e $no_sudo_conf >> /etc/sudoers
fi


# create script for system launch
log_command_info "Creating startup.sh..."
cat > /home/$(logname)/.config/startup.sh <<EOF
#!/bin/bash

# enable backlight color theme for keyboard
openrgb -p keyboard
EOF
check_success "Startup.sh created"


# enable bluetooth
log_command_info "Enabling bluetooth..."
systemctl start bluetooth
systemctl enable bluetooth
check_success "Bluetooth enabled"