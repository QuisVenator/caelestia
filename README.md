# caelestia

This is the main repo of the caelestia dots and contains user configs for
various apps.

> [!IMPORTANT]
> The legacy `install.fish` script in this repo has been deprecated in favour
> of the [CLI](https://github.com/caelestia-dots/cli)'s install command.
>
> If you have an existing installation with the legacy script, please update
> the CLI and run the install command to migrate.

Clone this repo and run the install script (you need
[`zsh`](https://www.zsh.org/) installed).

> [!IMPORTANT]
> We have switched to using Lua for the Hyprland config!
> For everyone with a custom `~/.config/caelestia/hypr-user.conf`
> or `~/.config/caelestia/hypr-vars.conf`, please convert it to Lua
> either manually, or using one of the available converters online.
>
> Usage for `hypr-vars.lua`:
>
> ```lua
> return {
>   browser = "chromium",
> }
> ```

## Installation (Arch Linux)

The install script has some options for installing configs for some apps.

```
$ ./install.zsh -h
usage: ./install.zsh [-h] [--noconfirm] [--spotify] [--vscode=code|codium] [--discord] [--yt-music] [--zen] [--aur-helper=yay|paru]

options:
  -h, --help                  show this help message and exit
  --noconfirm                 do not confirm package installation
  --spotify                   install Spotify (Spicetify)
  --vscode=[code|codium]      install VSCode or VSCodium
  --discord                   install Discord (OpenAsar + Equicord)
  --yt-music                  install YouTube Music desktop app
  --zen                       install Zen browser
  --aur-helper=[yay|paru]     the AUR helper to use (default: paru)
```

For example:

```sh
git clone https://github.com/QuisVenator/caelestia.git ~/.local/share/caelestia
~/.local/share/caelestia/install.zsh --vscode=code --yt-music --zen --discord
```

### Manual installation

Clone this repo, then go through [the manifest](/manifest.toml) and install all packages from the
components that you want to enable, then copy all the entries from those components.

-   hyprland
-   xdg-desktop-portal-hyprland
-   xdg-desktop-portal-gtk
-   hyprpicker
-   wl-clipboard
-   cliphist
-   inotify-tools
-   app2unit
-   wireplumber
-   trash-cli
-   zsh
-   oh-my-zsh
-   powerlevel10k
-   fastfetch
-   btop
-   jq
-   eza
-   adw-gtk-theme
-   papirus-icon-theme
-   quickshell-git
-   ttf-jetbrains-mono-nerd
-   ttf-material-symbols-variable-git
-   libcava
-   caelestia-cli
-   gnome-keyring

Install all dependencies and follow the installation guide of the
[cli](https://github.com/caelestia-dots/cli) to install it. Then build and
install the shell from [this fork](https://github.com/QuisVenator/caelestia-shell):

```sh
git clone https://github.com/QuisVenator/caelestia-shell.git
cd caelestia-shell
cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/
cmake --build build
sudo cmake --install build
```

Then copy or symlink the `hypr`, `fastfetch`, `uwsm` and `btop` folders to the
`$XDG_CONFIG_HOME` (usually `~/.config`) directory. e.g. `hypr -> ~/.config/hypr`.

Symlink `.zshrc` and `.p10k.zsh` from the `zsh/` folder to your home directory:

```sh
ln -s "$(realpath zsh/.zshrc)" ~/.zshrc
ln -s "$(realpath zsh/.p10k.zsh)" ~/.p10k.zsh
```

#### Installing Spicetify configs:

Follow the Spicetify [installation instructions](https://spicetify.app/docs/advanced-usage/installation),
copy or symlink the `spicetify` folder to `$XDG_CONFIG_HOME/spicetify` and run:

```sh
git clone https://github.com/caelestia-dots/caelestia.git
cd caelestia
sudo pacman -S --needed hyprland xdg-desktop-portal-hyprland xdg-desktop-portal-gtk ttf-jetbrains-mono-nerd
mkdir -p $XDG_CONFIG_HOME/hypr
cp -r hypr/. $XDG_CONFIG_HOME/hypr/
```

## Updating

Use `caelestia update` to perform a full system update and update the dots.

## Usage

> [!NOTE]
> These dots do not contain a login manager, so you must install one yourself
> unless you want to log in from a TTY. I recommend
> [`greetd`](https://sr.ht/~kennylevinsen/greetd) with
> [`tuigreet`](https://github.com/apognu/tuigreet), however you can use
> any login manager you want.

Here's a list of useful keybinds:

-   `Super` - open launcher
-   `Super` + `#` - switch to workspace `#`
-   `Super` `Alt` + `#` - move window to workspace `#`
-   `Super` + `T` - open terminal
-   `Super` + `W` - open browser (zen)
-   `Super` + `C` - open IDE (vscode)
-   `Super` + `S` - toggle special workspace or close current special workspace
-   `Ctrl` `Alt` + `Delete` - open session menu
-   `Ctrl` `Super` + `Space` - toggle media play state
-   `Ctrl` `Super` `Alt` + `R` - restart the shell