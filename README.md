# caelestia

This is the main repo of the caelestia dots and contains the user configs for
apps. This repo also includes an install script to install the entire dots.

## Installation

Clone this repo and run the install script (you need
[`zsh`](https://www.zsh.org/) installed).

> [!WARNING]
> The install script symlinks all configs into place, so you CANNOT
> move/remove the repo folder once you run the install script. If
> you do, most apps will not behave properly and some (e.g. Hyprland)
> will fail to start completely. I recommend cloning the repo to
> `~/.local/share/caelestia`.

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
git clone https://github.com/QuisVenator/caelestia-shell.git ~/.local/share/caelestia
~/.local/share/caelestia/install.zsh --vscode=code --yt-music --zen --discord
```

### Manual installation

Dependencies:

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
spicetify config current_theme caelestia color_scheme caelestia custom_apps marketplace
spicetify apply
```

#### Installing VSCode/VSCodium configs:

Install VSCode or VSCodium, then copy or symlink `vscode/settings.json` and
`vscode/keybindings.json` into the `$XDG_CONFIG_HOME/Code/User` (or `$XDG_CONFIG_HOME/VSCodium/User`
if using VSCodium) folder. Then copy or symlink `vscode/flags.conf` to `$XDG_CONFIG_HOME/code-flags.conf`
(or `$XDG_CONFIG_HOME/codium-flags.conf` if using VSCodium).

Finally, install the extension VSIX from `vscode/caelestia-vscode-integration`:

```sh
# Use `codium` if using VSCodium
code --install-extension vscode/caelestia-vscode-integration/caelestia-vscode-integration-*.vsix
```

#### Installing Zen Browser configs:

Install Zen Browser, then copy or symlink `zen/userChrome.css` to the `chrome` folder in your
profile of choice in `~/.zen`. e.g. `zen/userChrome.css -> ~/.zen/<profile>/chrome/userChrome.css`.

Now install the native app by copying `zen/native_app/manifest.json` to
`~/.mozilla/native-messaging-hosts/caelestiafox.json` and replacing the `{{ $lib }}` string in it
with the absolute path of `~/.local/lib/caelestia` (this must be the absolute path, e.g.
`/home/user/.local/lib/caelestia`). Then copy or symlink `zen/native_app/app.zsh` to
`~/.local/lib/caelestia/caelestiafox`.

Finally, install the CaelestiaFox extension from [here](https://addons.mozilla.org/en-US/firefox/addon/caelestiafox).

## Updating

Run your AUR helper to update AUR packages, then `cd` into the repo directory and run `git pull`
to update the configs. To sync with upstream caelestia changes, fetch and rebase:

```sh
git fetch upstream
git checkout main
git merge upstream/main --ff-only
git checkout personal
git rebase main
```

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