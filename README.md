# dotfiles

Personal configuration for a Fedora + Sway laptop, linked into `$HOME` with
[GNU Stow](https://www.gnu.org/software/stow/). The repo mirrors the home
directory: `.config/sway` here is `~/.config/sway` there.

## Install

```bash
sudo dnf install stow
git clone https://github.com/Ado-do/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
stow -n -v .   # dry run: shows the links, reports conflicts
stow -v .
```

Stow refuses to overwrite existing files, so move any conflicting file out of
the way first. `stow -D .` removes the links again.

## Dependencies

Nothing here installs software; the configs only call it. A missing tool
breaks just the feature that uses it. The shell's "pretty" replacements
(`eza` for `ls`, `bat` for `cat` and man pages, `vimx` for `vim`, fzf previews)
are optional: without them the plain command is used.

**Fedora packages (dnf)**

```bash
# Desktop: sway session, bar, launcher, notifications, screenshots, power
sudo dnf install sway swaybg swayidle swaylock waybar foot fuzzel kanshi dunst \
    grim slurp wl-clipboard wl-mirror wlsunset brightnessctl playerctl \
    pulseaudio-utils pavucontrol wiremix nm-connection-editor upower tlp tlp-pd \
    libnotify jq socat mpv python3-gobject gtk3 gtk-layer-shell \
    papirus-icon-theme fontawesome-6-free-fonts fontawesome-6-brands-fonts
# Shell and terminal tools
sudo dnf install tmux fzf fd-find zoxide bat tree glow vim-X11 btop zathura kitty
```

**Installed outside dnf**

| Tool | Used by | Install with |
|---|---|---|
| Neovim ≥ 0.11 | `nvim`, `lazyvim` configs | upstream release in `/usr/local` |
| eza, yazi, neovide, rmpc, termusic, bluetui, wlctl, wl-clip-persist | `ls`, file manager, music, waybar Bluetooth/Wi-Fi, clipboard | `cargo install <name>` |
| soteria (polkit password prompt) | sway autostart | build from source: `cargo install --locked --path .` |
| cliphist | clipboard history binding | `go install go.senan.xyz/cliphist@latest` |
| fnm, lazygit, typst | Node versions, `lg`, LazyVim typst | Homebrew |
| calcure | waybar calendar click | `uv tool install calcure` |
| obs-cmd | OBS recording binding | release binary into `~/.local/bin` |
| translate-shell (`trans`) | `tr_enes`, `tr_esen` aliases | upstream script in `/usr/local/bin` |

**Fonts and images (not packaged)**

- Fonts in `~/.local/share/fonts`: IosevkaTerm Nerd Font (fuzzel, waybar,
  foot), Symbols Nerd Font (waybar icons), IBM Plex Serif (swaylock).
- Wallpapers: `~/Pictures/backgrounds/galaxy1.png` (sway) and
  `~/Pictures/backgrounds/music/slowdive5-2.png` (swaylock).

## Daily use

Whole folders are symlinks, so editing a file in `~/.config/...` edits the repo.

```bash
cd ~/.dotfiles
git status          # what changed, including new files
git add -A && git commit
```

To manage a new program, move its folder in and re-link:

```bash
mv ~/.config/foo ~/.dotfiles/.config/foo && cd ~/.dotfiles && stow -v .
```

Personal scripts in `.local/bin` are linked one file at a time (other programs
also live in `~/.local/bin`), so a new script needs the same move + `stow -v .`.

## Local files (not in the repo)

These are gitignored and must be created by hand on a new machine:

| File | Purpose |
|---|---|
| `.config/git/config.local` | `[user]` block with name and email |
| `.config/waybar/lastfm.json` | Last.fm credentials; copy `lastfm.json.example` |
| `.bashrc.d/local.sh` | personal aliases |
| `.config/sway/config.d/61-bindings-local.conf` | personal key bindings |

## After cloning

- tmux plugins: install TPM, then `prefix + I`.
- waybar theme: run `~/.config/waybar/scripts/theme.sh neutral` to generate `style.css`.
