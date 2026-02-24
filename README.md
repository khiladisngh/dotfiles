# dotfiles

Modern ZSH dotfiles for Fedora & Ubuntu — starship, eza, bat, fzf, atuin and more.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/khiladisngh/dotfiles/main/install.sh | sudo bash
```

No cloning required. The script downloads everything it needs automatically.

To overwrite existing config files:

```bash
curl -fsSL https://raw.githubusercontent.com/khiladisngh/dotfiles/main/install.sh | sudo bash -s -- --force
```

<!-- screenshot placeholder -->

## What's included

| Tool | Replaces | Description |
|------|----------|-------------|
| [zsh](https://www.zsh.org/) | bash | Shell with rich completion & plugins |
| [starship](https://starship.rs/) | default prompt | Blazing-fast, cross-shell prompt |
| [eza](https://github.com/eza-community/eza) | `ls` | Modern file lister with icons & git integration |
| [bat](https://github.com/sharkdp/bat) | `cat` | Syntax-highlighted file viewer |
| [fd](https://github.com/sharkdp/fd) | `find` | Fast, user-friendly file finder |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | `grep` | Blazing-fast recursive search |
| [fzf](https://github.com/junegunn/fzf) | — | Fuzzy finder for files, history, processes |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | `cd` | Smarter directory jumping |
| [atuin](https://github.com/atuinsh/atuin) | shell history | Searchable, syncable shell history |
| [btop](https://github.com/aristocratsofcode/btop) | `top` / `htop` | Resource monitor |
| [dust](https://github.com/bootandy/dust) | `du` | Intuitive disk usage viewer |
| [duf](https://github.com/muesli/duf) | `df` | Better disk usage/free utility |
| [procs](https://github.com/dalance/procs) | `ps` | Modern process viewer |
| [lazygit](https://github.com/jesseduffield/lazygit) | `git` TUI | Terminal UI for git |
| [git-delta](https://github.com/dandavison/delta) | `git diff` | Syntax-highlighted diffs |
| [tealdeer](https://github.com/dbrgn/tealdeer) | `man` | Fast tldr pages |

## Prerequisites

- **Fedora 40+** (tested on Fedora 43) or **Ubuntu 22.04 LTS / 24.04 LTS**
- **A [Nerd Font](https://www.nerdfonts.com/)** installed and set as your terminal font (required for icons)
  - Recommended: `FiraCode Nerd Font`, `JetBrainsMono Nerd Font`, or `CascadiaCode Nerd Font`

Already installed on most Fedora systems: `bat`, `fd-find`, `ripgrep`, `fzf`, `zoxide`, `btop`

On Ubuntu, the installer handles all package installs automatically — nothing needs to be pre-installed.

## Quick install

**One-liner (no clone needed):**

```bash
curl -fsSL https://raw.githubusercontent.com/khiladisngh/dotfiles/main/install.sh | sudo bash
```

**Or clone and run:**

```bash
git clone https://github.com/khiladisngh/dotfiles.git ~/Dev/repos/dotfiles
cd ~/Dev/repos/dotfiles
sudo bash install.sh
```

Then log out and back in (or run `exec zsh`) to start using the new shell.

### Re-running on an existing setup

By default the installer **skips** `.zshrc` and `starship.toml` if they already exist, so it's safe to re-run to update tools:

```bash
curl -fsSL https://raw.githubusercontent.com/khiladisngh/dotfiles/main/install.sh | sudo bash
```

To also overwrite config files, pass `--force` via `-s --`:

```bash
curl -fsSL https://raw.githubusercontent.com/khiladisngh/dotfiles/main/install.sh | sudo bash -s -- --force
```

## Repo structure

```
dotfiles/
├── README.md          — this file
├── install.sh         — idempotent setup script
├── zshrc              — ZSH configuration (~/.zshrc)
└── config/
    └── starship.toml  — Starship prompt config (~/.config/starship.toml)
```

## What `install.sh` does

1. Detects distro and installs packages via DNF (Fedora) or APT (Ubuntu): `zsh`, `duf`, `zsh-autosuggestions`, `zsh-syntax-highlighting`, and more
   - **Ubuntu only**: also installs `ripgrep`, `fzf`, `zoxide`, `btop`, `bat`, `fd-find` via APT; creates `~/.local/bin/bat` and `~/.local/bin/fd` symlinks (Ubuntu renames these binaries)
   - **Ubuntu only**: installs `atuin` via official script, `procs` and `git-delta` via GitHub `.deb` releases
2. Installs `tealdeer` (package manager or GitHub binary fallback)
3. Installs `starship` prompt
4. Installs `eza` from GitHub releases
5. Installs `lazygit` from GitHub releases
6. Installs `dust` from GitHub releases
7. Sets ZSH as the default shell
8. Configures git to use `delta` for diffs
9. Copies `zshrc` → `~/.zshrc` and `config/starship.toml` → `~/.config/starship.toml` (skipped if files exist, unless `--force`)

## Key aliases & shortcuts

| Alias | Command | Description |
|-------|---------|-------------|
| `ll` | `eza -la --git` | Detailed list with git status |
| `lt` | `eza --tree` | Directory tree |
| `cat` | `bat` | Syntax-highlighted file view |
| `find` | `fd` | Fast file search |
| `grep` | `rg` | Fast content search |
| `top` | `btop` | Resource monitor |
| `du` | `dust` | Disk usage |
| `df` | `duf` | Disk free |
| `ps` | `procs` | Process list |
| `lg` | `lazygit` | Git TUI |
| `j <dir>` | `zoxide` | Jump to frecent directory |
| `ji` | `zoxide` + fzf | Interactive directory jump |

## License

MIT
