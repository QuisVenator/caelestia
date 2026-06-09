#!/bin/zsh

# Load zsh modules for argument parsing and colors
zmodload zsh/zutil
autoload -U colors && colors

# ---------------------------------------------------------
# CONFIGURATION
# ---------------------------------------------------------
MY_SHELL_FORK="https://github.com/QuisVenator/caelestia-shell.git"

# 1. Official Repo Dependencies (Pacman)
DEPENDENCIES=(
    # Core Hyprland & Wayland Utils
    "hyprland" "xdg-desktop-portal-hyprland" "hyprpicker"
    "wl-clipboard" "cliphist" "inotify-tools" "trash-cli"

    # Theming & Visuals
    "eza" "fastfetch" "btop" "jq"
    "adw-gtk-theme" "papirus-icon-theme" "ttf-jetbrains-mono-nerd"
    "ttf-cascadia-code-nerd" "thefuck" "pyenv"

    # Audio/Video/Hardware Control
    "wireplumber" "libpipewire" "aubio"
    "ddcutil" "brightnessctl" "lm_sensors" "swappy"

    # Qt / Libraries / Tools
    "qt6-base" "qt6-declarative" "gcc-libs" "glibc" "libqalculate"
    "cmake" "ninja" "bash"
    "gnome-keyring" "seahorse"
)

# 2. AUR Dependencies (Yay/Paru)
AUR_DEPENDENCIES=(
    "app2unit"
    "quickshell-git"
    "caelestia-cli"
    "qt5ct-kde"
    "qt6ct-kde"
    "ttf-material-symbols-variable-git"
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
    -yt-music \
    -zen \
    -aur-helper:

if [[ -n "${opts[(i)-h]}" || -n "${opts[(i)--help]}" ]]; then
    echo "usage: ./install.zsh [-h] [--noconfirm] [--spotify] [--vscode=code|codium] [--discord] [--yt-music] [--zen] [--aur-helper=yay|paru]"
    echo
    echo "options:"
    echo "  -h, --help                  show this help message and exit"
    echo "  --noconfirm                 do not confirm package installation"
    echo "  --spotify                   install Spotify (Spicetify)"
    echo "  --vscode=[code|codium]      install VSCode or VSCodium"
    echo "  --discord                   install Discord (OpenAsar + Equicord)"
    echo "  --yt-music                  install YouTube Music desktop app"
    echo "  --zen                       install Zen browser"
    echo "  --aur-helper=[yay|paru]     the AUR helper to use (default: paru)"
    exit 0
fi

# Validate --vscode value
if [[ -n "${opts[(i)--vscode]}" ]]; then
    local vscode_val="${opts[--vscode]}"
    if [[ "$vscode_val" != "code" && "$vscode_val" != "codium" ]]; then
        echo "Error: --vscode must be 'code' or 'codium'" >&2
        exit 1
    fi
fi

# Validate --aur-helper value
if [[ -n "${opts[(i)--aur-helper]}" ]]; then
    local helper_val="${opts[--aur-helper]}"
    if [[ "$helper_val" != "yay" && "$helper_val" != "paru" ]]; then
        echo "Error: --aur-helper must be 'yay' or 'paru'" >&2
        exit 1
    fi
fi

# Set variables based on flags
NOCONFIRM=""
[[ -n "${opts[(i)--noconfirm]}" ]] && NOCONFIRM="--noconfirm"

AUR_HELPER="paru"
[[ -n "${opts[(i)--aur-helper]}" ]] && AUR_HELPER="${opts[--aur-helper]}"

# XDG Paths
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}"

# Script directory (so symlinks point to the right place regardless of cwd)
SCRIPT_DIR="${0:a:h}"

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
    local target_path="$1"
    if [[ -e "$target_path" || -L "$target_path" ]]; then
        if [[ -n "$NOCONFIRM" ]]; then
            log "$target_path already exists. Overwriting..."
            rm -rf "$target_path"
            return 0
        else
            input_prompt "$target_path already exists. Overwrite? [Y/n] "
            local confirm
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
    log "[1] Two steps ahead of you!  [2] Make one for me please!"
    input_prompt "=> "
    local choice
    read -r choice
    if [[ "$choice" == "1" || "$choice" == "2" ]]; then
        if [[ "$choice" == "2" ]]; then
            log "Backing up $CONFIG_DIR..."
            if [[ -e "$CONFIG_DIR.bak" || -L "$CONFIG_DIR.bak" ]]; then
                input_prompt "Backup already exists. Overwrite? [Y/n] "
                local overwrite
                read -r overwrite
                if [[ "$overwrite" =~ ^[Nn]$ ]]; then
                    log "Skipping backup..."
                else
                    rm -rf "$CONFIG_DIR.bak"
                    cp -r "$CONFIG_DIR" "$CONFIG_DIR.bak"
                fi
            else
                cp -r "$CONFIG_DIR" "$CONFIG_DIR.bak"
            fi
        fi
    else
        log "No valid choice selected. Exiting..."
        exit 1
    fi
fi

# 2. Check/Install AUR Helper
if ! pacman -Q "$AUR_HELPER" &>/dev/null; then
    log "$AUR_HELPER not installed. Installing..."
    sudo pacman -S --needed git base-devel --noconfirm
    cd /tmp
    git clone "https://aur.archlinux.org/$AUR_HELPER.git"
    cd "$AUR_HELPER"
    makepkg -si
    cd - >/dev/null
    rm -rf "/tmp/$AUR_HELPER"

    # Post-install setup
    if [[ "$AUR_HELPER" == "yay" ]]; then
        yay -Y --gendb
        yay -Y --devel --save
    else
        paru --gendb
    fi
fi

# Change to script directory
cd "$SCRIPT_DIR" || exit 1

# 3. Install Dependencies
log "Installing system dependencies..."
sudo pacman -S --needed "${DEPENDENCIES[@]}" $NOCONFIRM

log "Installing AUR dependencies..."
$AUR_HELPER -S --needed "${AUR_DEPENDENCIES[@]}" $NOCONFIRM

# 4. Custom Caelestia Shell Build (Your Fork)
QS_TARGET="$CONFIG_DIR/quickshell/caelestia"

if confirm_overwrite "$QS_TARGET"; then
    log "Cloning custom shell from $MY_SHELL_FORK..."
    mkdir -p "$(dirname "$QS_TARGET")"
    git clone "$MY_SHELL_FORK" "$QS_TARGET"

    if [[ -d "$QS_TARGET" ]]; then
        log "Building Caelestia Shell..."
        pushd "$QS_TARGET" >/dev/null

        cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/
        cmake --build build
        sudo cmake --install build

        popd >/dev/null
        log "Shell built successfully!"
    else
        log "Error: Clone failed."
        exit 1
    fi
fi

# 5. Link Configs

# Hyprland
if confirm_overwrite "$CONFIG_DIR/hypr"; then
    log "Linking hypr configs..."
    ln -s "$(realpath hypr)" "$CONFIG_DIR/hypr"
    chmod u+x "$CONFIG_DIR/hypr/scripts/wsaction.zsh" 2>/dev/null || true
    hyprctl reload
fi

# Oh My Zsh
if confirm_overwrite "$HOME/.oh-my-zsh"; then
    log "Installing Oh My Zsh..."
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Powerlevel10k theme
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if confirm_overwrite "$P10K_DIR"; then
    log "Installing Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
fi

# Zsh — use $HOME/.zshrc, not "~/.zshrc" (tilde is not expanded in [[ -e ... ]])
if confirm_overwrite "$HOME/.zshrc"; then
    log "Linking zsh config..."
    ln -s "$(realpath zsh/.zshrc)" "$HOME/.zshrc"
fi

# p10k config
if confirm_overwrite "$HOME/.p10k.zsh"; then
    log "Linking p10k config..."
    ln -s "$(realpath zsh/.p10k.zsh)" "$HOME/.p10k.zsh"
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

# 6. Optional Apps

# Spotify
if [[ -n "${opts[(i)--spotify]}" ]]; then
    log "Installing Spotify..."
    local has_spicetify
    has_spicetify=$(pacman -Q spicetify-cli 2>/dev/null)
    $AUR_HELPER -S --needed spotify spicetify-cli spicetify-marketplace-bin $NOCONFIRM

    # Only chmod and init if spicetify wasn't already installed
    if [[ -z "$has_spicetify" ]]; then
        sudo chmod a+wr /opt/spotify
        sudo chmod a+wr /opt/spotify/Apps -R
        spicetify backup apply
    fi

    if confirm_overwrite "$CONFIG_DIR/spicetify"; then
        log "Linking spicetify config..."
        ln -s "$(realpath spicetify)" "$CONFIG_DIR/spicetify"
        spicetify config current_theme caelestia color_scheme caelestia custom_apps marketplace
        spicetify apply
    fi
fi

# VSCode / VSCodium
if [[ -n "${opts[(i)--vscode]}" ]]; then
    local vscode_val="${opts[--vscode]}"
    local prog folder packages

    if [[ "$vscode_val" == "code" ]]; then
        prog="code"
        folder="Code"
        packages=("code")
    else
        prog="codium"
        folder="VSCodium"
        packages=("vscodium-bin" "vscodium-bin-marketplace")
    fi

    local user_dir="$CONFIG_DIR/$folder/User"

    log "Installing vs$prog..."
    $AUR_HELPER -S --needed "${packages[@]}" $NOCONFIRM

    mkdir -p "$user_dir"

    if confirm_overwrite "$user_dir/settings.json" && \
       confirm_overwrite "$user_dir/keybindings.json" && \
       confirm_overwrite "$CONFIG_DIR/$prog-flags.conf"; then
        log "Linking vs$prog config..."
        ln -s "$(realpath vscode/settings.json)" "$user_dir/settings.json"
        ln -s "$(realpath vscode/keybindings.json)" "$user_dir/keybindings.json"
        ln -s "$(realpath vscode/flags.conf)" "$CONFIG_DIR/$prog-flags.conf"

        # Install the caelestia vscode extension
        local vsix=(vscode/caelestia-vscode-integration/caelestia-vscode-integration-*.vsix)
        if [[ -f "${vsix[1]}" ]]; then
            $prog --install-extension "${vsix[1]}"
        else
            log "Warning: Could not find caelestia vscode extension .vsix file."
        fi
    fi
fi

# YouTube Music Desktop App
if [[ -n "${opts[(i)--yt-music]}" ]]; then
    log "Installing YouTube Music Desktop App..."
    $AUR_HELPER -S --needed pear-desktop $NOCONFIRM
fi

# Discord
if [[ -n "${opts[(i)--discord]}" ]]; then
    log "Installing Discord..."
    $AUR_HELPER -S --needed discord equicord-installer-bin $NOCONFIRM
    sudo Equilotl -install -location /opt/discord
    sudo Equilotl -install-openasar -location /opt/discord
    # Remove installer after use
    $AUR_HELPER -Rns equicord-installer-bin $NOCONFIRM
fi

# Zen Browser
if [[ -n "${opts[(i)--zen]}" ]]; then
    log "Installing Zen..."
    $AUR_HELPER -S --needed zen-browser-bin $NOCONFIRM

    # Install userChrome css
    local chrome_dirs=($HOME/.zen/*/chrome(N))
    local chrome="${chrome_dirs[1]}"

    if [[ -n "$chrome" ]]; then
        if confirm_overwrite "$chrome/userChrome.css"; then
            log "Installing zen userChrome..."
            ln -sf "$(realpath zen/userChrome.css)" "$chrome/userChrome.css"
        fi
    else
        log "Warning: Could not find Zen browser chrome directory."
    fi

    # Install native app
    local hosts="$HOME/.mozilla/native-messaging-hosts"
    local lib="$HOME/.local/lib/caelestia"

    if confirm_overwrite "$hosts/caelestiafox.json"; then
        log "Installing zen native app manifest..."
        mkdir -p "$hosts"
        cp zen/native_app/manifest.json "$hosts/caelestiafox.json"
        sed -i "s|{{ \$lib }}|$lib|g" "$hosts/caelestiafox.json"
    fi

    if confirm_overwrite "$lib/caelestiafox"; then
        log "Installing zen native app..."
        mkdir -p "$lib"
        ln -sf "$(realpath zen/native_app/app.zsh)" "$lib/caelestiafox"
    fi

    log "Please install the CaelestiaFox extension from https://addons.mozilla.org/en-US/firefox/addon/caelestiafox if you have not already done so."
fi

# 7. Final Setup

# Generate color scheme if missing
if [[ ! -f "$STATE_DIR/caelestia/scheme.json" ]]; then
    if command -v caelestia &>/dev/null; then
        log "Generating initial color scheme..."
        caelestia scheme set -n shadotheme
        sleep 0.5
        hyprctl reload
    else
        log "Warning: caelestia-cli not found. Skipping scheme generation."
    fi
fi

# Start the shell
caelestia shell -d >/dev/null

log "Done!"