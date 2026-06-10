# dotfiles

Personal macOS dev environment, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## New machine

```sh
git clone https://github.com/paulpjryan/dotfiles.git ~/dotfiles
~/dotfiles/bootstrap.sh
```

`bootstrap.sh` is idempotent. It installs Homebrew + packages, `oh-my-zsh`, and
the spaceship prompt; then symlinks the config into `$HOME` and seeds local
overlay files from their `.example` templates.

After it runs, fill in the seeded secrets and open a new shell:

```sh
$EDITOR ~/.zsh-custom/secrets.zsh   # tokens
$EDITOR ~/.gitconfig.local          # user.email for this machine
```

## Layout

```
Brewfile                       general packages (every machine)
Brewfile.work.example          template for work-only packages
bootstrap.sh                   idempotent installer
zsh/.zshrc                     -> ~/.zshrc
zsh/.zsh-custom/custom.zsh     -> ~/.zsh-custom/custom.zsh  (oh-my-zsh $ZSH_CUSTOM)
zsh/.zsh-custom/*.example      templates for local overlays
git/.gitconfig                 -> ~/.gitconfig  (includes ~/.gitconfig.local)
git/.gitconfig.local.example   template for machine identity
```

`$ZSH_CUSTOM` points at `~/.zsh-custom` (set in `.zshrc`) so oh-my-zsh updates
never touch these files, and so local overlays can live beside the tracked ones.
Stow uses `--no-folding` to keep `~/.zsh-custom` a real directory for that reason.

## Public vs. local

This repo is **public**. Anything secret or employer-specific stays out of it and
is gitignored:

| Tracked (public)            | Local only (gitignored)        |
| --------------------------- | ------------------------------ |
| `Brewfile`                  | `Brewfile.work`                |
| `secrets.zsh.example`       | `~/.zsh-custom/secrets.zsh`    |
| `company.zsh.example`       | `~/.zsh-custom/company.zsh`     |
| `.gitconfig.local.example`  | `~/.gitconfig.local`           |

On a work machine, copy the `.example` files to their real names and re-run
`bootstrap.sh`.
