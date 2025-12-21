#!/bin/zsh

# Load zsh modules for argument parsing and colors
zmodload zsh/zutil
autoload -U colors && colors

# ---------------------------------------------------------
# CONFIGURATION
# ---------------------------------------------------------
MY_SHELL_FORK="git@github.com:QuisVenator/caelestia-shell.git" 

# 1. Official Repo Dependencies (Pacman)
DEPENDENCIES=(
    # Core Hyprland & Wayland Utils
    "hyprland" "xdg-desktop-portal-hyprland" "hyprpicker"
    "wl-clipboard" "cliphist" "inotify-tools" "trash-cli"
    
    # Theming & Visuals
    "eza" "fastfetch" "starship" "btop" "jq"
    "adw-gtk-theme" "papirus-icon-theme" "ttf-jetbrains-mono-nerd"
    "ttf-cascadia-code-nerd"  # Corresponds to 'caskaydia-cove-nerd'
    
    # Audio/Video/Hardware Control
    "wireplumber" "libpipewire" "aubio"
    "ddcutil" "brightnessctl" "lm_sensors" "swappy"
    
    # Qt / Libraries / Tools
    "qt6-base" "qt6-declarative" "gcc-libs" "glibc" "libqalculate"
    "cmake" "ninja" "bash" "fish" # Fish is required by the shell widgets backend
    "gnome-keyring" "seahorse"
)

# 2. AUR Dependencies (Yay/Paru)
AUR_DEPENDENCIES=(
    "app2unit" 
    "quickshell-git" 
    "caelestia-cli"      # Required CLI tool
    "qt5ct-kde"          # Could maybe be replaced with qt6ct, but everyone recommends this
    "qt6ct-kde"          # Could maybe be replaced with qt6ct, but everyone recommends this
    "ttf-material-symbols-variable-git" # Icon font required by shell
    "libcava"
)

# ---------------------------------------------------------
# ARGUMENT PARSING
# ---------------------------------------------------------
zparseopts -D -E -A opts -- \
    h -help \
    -noconfirm \
    -spotify \
    -vscode: \
    -discord \
    -zen \
    -aur-helper:

if [[ -n "${opts[(i)-h]}" || -n "${opts[(i)--help]}" ]]; then
    echo "usage: ./install.zsh [-h] [--noconfirm] [--spotify] [--vscode=code|codium] [--discord] [--zen] [--aur-helper=yay|paru]"
    exit 0
fi

# Set variables based on flags
NOCONFIRM=""
[[ -n "${opts[(i)--noconfirm]}" ]] && NOCONFIRM="--noconfirm"

AUR_HELPER="paru"
[[ -n "${opts[(i)--aur-helper]}" ]] && AUR_HELPER="${opts[--aur-helper]}"

# XDG Paths
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}"

# ---------------------------------------------------------
# HELPER FUNCTIONS
# ---------------------------------------------------------
log() {
    echo "$fg[cyan]:: $1$reset_color"
}

input_prompt() {
    echo -n "$fg[blue]:: $1$reset_color"
}

confirm_overwrite() {
    local target_path="$1"  # CHANGED NAME HERE
    if [[ -e "$target_path" || -L "$target_path" ]]; then
        if [[ -n "$NOCONFIRM" ]]; then
            log "$target_path already exists. Overwriting..."
            rm -rf "$target_path"
            return 0
        else
            input_prompt "$target_path already exists. Overwrite? [Y/n] "
            read -r confirm
            if [[ "$confirm" =~ ^[Nn]$ ]]; then
                log "Skipping..."
                return 1
            else
                log "Removing old config..."
                rm -rf "$target_path"
                return 0
            fi
        fi
    fi
    return 0
}

# ---------------------------------------------------------
# MAIN SCRIPT
# ---------------------------------------------------------

# Banner
echo "$fg[magenta]"
echo '╭─────────────────────────────────────────────────╮'
echo '│       ______           __          __  _        │'
echo '│      / ____/___ ____  / /__  _____/ /_(_)___ _  │'
echo '│     / /   / __ `/ _ \/ / _ \/ ___/ __/ / __ `/  │'
echo '│    / /___/ /_/ /  __/ /  __(__  ) /_/ / /_/ /   │'
echo '│    \____/\__,_/\___/_/\___/____/\__/_/\__,_/    │'
echo '╰─────────────────────────────────────────────────╯'
echo "$reset_color"
log "Welcome to the Caelestia dotfiles installer (Zsh Edition)!"

# 1. Backup Prompt
if [[ -z "$NOCONFIRM" ]]; then
    log "[1] Backup my config first!  [2] YOLO (No backup)"
    input_prompt "=> "
    read -r choice
    if [[ "$choice" == "1" ]]; then
        log "Backing up $CONFIG_DIR..."
        cp -r "$CONFIG_DIR" "$CONFIG_DIR.bak"
    fi
fi

# 2. Check/Install AUR Helper
if ! pacman -Q "$AUR_HELPER" &> /dev/null; then
    log "$AUR_HELPER not installed. Installing..."
    sudo pacman -S --needed git base-devel --noconfirm
    cd /tmp
    git clone "https://aur.archlinux.org/$AUR_HELPER.git"
    cd "$AUR_HELPER"
    makepkg -si
    cd - > /dev/null
    rm -rf "/tmp/$AUR_HELPER"
fi

# Change to script directory
SCRIPT_DIR=${0:a:h}
cd "$SCRIPT_DIR" || exit 1

# 3. Install Dependencies
log "Installing system dependencies..."
sudo pacman -S --needed "${DEPENDENCIES[@]}" --noconfirm

log "Installing AUR dependencies..."
$AUR_HELPER -S --needed "${AUR_DEPENDENCIES[@]}" --noconfirm

# 4. Custom Caelestia Shell Build (Your Fork)
QS_TARGET="$CONFIG_DIR/quickshell/caelestia"

if confirm_overwrite "$QS_TARGET"; then
    log "Cloning custom shell from $MY_SHELL_FORK..."
    mkdir -p "$(dirname "$QS_TARGET")"
    git clone "$MY_SHELL_FORK" "$QS_TARGET"
    
    if [[ -d "$QS_TARGET" ]]; then
        log "Building Caelestia Shell..."
        pushd "$QS_TARGET" > /dev/null
        
        cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/
        cmake --build build
        sudo cmake --install build
        
        popd > /dev/null
        log "Shell built successfully!"
    else
        log "Error: Clone failed."
    fi
fi

# 5. Link Configs
# Hyprland
if confirm_overwrite "$CONFIG_DIR/hypr"; then
    log "Linking hypr configs..."
    ln -s "$(realpath hypr)" "$CONFIG_DIR/hypr"
fi

# Starship
if confirm_overwrite "$CONFIG_DIR/starship.toml"; then
    log "Linking starship config..."
    ln -s "$(realpath starship.toml)" "$CONFIG_DIR/starship.toml"
fi

# Fastfetch
if confirm_overwrite "$CONFIG_DIR/fastfetch"; then
    log "Linking fastfetch config..."
    ln -s "$(realpath fastfetch)" "$CONFIG_DIR/fastfetch"
fi

# Uwsm
if confirm_overwrite "$CONFIG_DIR/uwsm"; then
    log "Linking uwsm config..."
    ln -s "$(realpath uwsm)" "$CONFIG_DIR/uwsm"
fi

# Btop
if confirm_overwrite "$CONFIG_DIR/btop"; then
    log "Linking btop config..."
    ln -s "$(realpath btop)" "$CONFIG_DIR/btop"
fi

# NOTE: Skipped foot and fish configs (as user uses Kitty/Zsh)

# 6. Optional Apps
# Spotify
if [[ -n "${opts[(i)--spotify]}" ]]; then
    log "Installing Spotify..."
    $AUR_HELPER -S --needed spotify spicetify-cli spicetify-marketplace-bin --noconfirm
    sudo chmod a+wr /opt/spotify
    sudo chmod a+wr /opt/spotify/Apps -R
    spicetify backup apply
    
    if confirm_overwrite "$CONFIG_DIR/spicetify"; then
        ln -s "$(realpath spicetify)" "$CONFIG_DIR/spicetify"
        spicetify config current_theme caelestia color_scheme caelestia custom_apps marketplace
        spicetify apply
    fi
fi

# Discord
if [[ -n "${opts[(i)--discord]}" ]]; then
    log "Installing Discord..."
    $AUR_HELPER -S --needed discord equicord-installer-bin --noconfirm
    sudo Equilotl -install -location /opt/discord
    sudo Equilotl -install-openasar -location /opt/discord
fi

# 7. Final Setup
# Generate scheme if missing
if [[ ! -f "$STATE_DIR/caelestia/scheme.json" ]]; then
    if command -v caelestia &> /dev/null; then
        log "Generating initial color scheme..."
        caelestia scheme set -n shadotheme
    else
        log "Warning: caelestia-cli not found. Skipping scheme generation."
    fi
fi

log "Done! Please restart Hyprland."
