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
