#!/bin/bash
# ============================================================
# Modern Shell Setup — Fedora & Ubuntu
# Run via pipe:  curl -fsSL https://raw.githubusercontent.com/khiladisngh/dotfiles/main/install.sh | sudo bash
# Run via clone: sudo bash install.sh [--force]
#
# --force   Overwrite existing .zshrc / starship.toml
# ============================================================
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd 2>/dev/null)" || SCRIPT_DIR=""

# ── Self-bootstrap when run via pipe ─────────────────────────
# If the config files aren't next to this script (e.g. curl | sudo bash),
# download the full repo tarball and re-exec from there.
if [[ ! -f "$SCRIPT_DIR/zshrc" ]]; then
    echo "[INFO] Running from pipe — downloading dotfiles repo..."
    DOTFILES_TMP=$(mktemp -d)
    curl -fsSL "https://github.com/khiladisngh/dotfiles/archive/refs/heads/main.tar.gz" \
        | tar -xz -C "$DOTFILES_TMP" --strip-components=1
    exec bash "$DOTFILES_TMP/install.sh" "$@"
fi

FORCE=false
[[ "${1:-}" == "--force" ]] && FORCE=true

USER_NAME="${SUDO_USER:-$USER}"
USER_HOME=$(eval echo ~"$USER_NAME")
ARCH="x86_64"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

info()    { echo -e "${CYAN}[INFO]${RESET} $*"; }
success() { echo -e "${GREEN}[OK]${RESET}  $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET} $*"; }
step()    { echo -e "\n${BOLD}${CYAN}══ $* ══${RESET}"; }

# ── Detect OS ─────────────────────────────────────────────
source /etc/os-release 2>/dev/null || true
case "${ID:-}" in
    fedora)        DISTRO="fedora" ;;
    ubuntu|debian) DISTRO="ubuntu" ;;
    *)
        if [[ "${ID_LIKE:-}" == *"debian"* ]]; then
            DISTRO="ubuntu"
        else
            echo "Unsupported distro: ${ID:-unknown}. Only Fedora and Ubuntu/Debian are supported."
            exit 1
        fi
        ;;
esac
info "Detected distro: $DISTRO"

# Install a package, warn on failure instead of aborting
pkg_install() {
    local pkg="$1"
    if [[ "$DISTRO" == "fedora" ]]; then
        dnf install -y "$pkg" &>/dev/null && success "$pkg installed" || { warn "$pkg failed via DNF"; return 1; }
    else
        apt-get install -y "$pkg" &>/dev/null && success "$pkg installed" || { warn "$pkg failed via APT"; return 1; }
    fi
}

# ── Must run as root ─────────────────────────────────────────
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}Run with sudo:${RESET} sudo bash install.sh"
    exit 1
fi

install_config() {
    local src="$1" dst="$2" label="$3"
    if [[ -f "$dst" ]] && [[ "$FORCE" == false ]]; then
        warn "$label already exists at $dst — skipping (run with --force to overwrite)"
    else
        mkdir -p "$(dirname "$dst")"
        cp "$src" "$dst"
        chown "$USER_NAME:$USER_NAME" "$dst"
        success "$label installed → $dst"
    fi
}

step "1. Installing packages via package manager (one by one to isolate failures)"
if [[ "$DISTRO" == "fedora" ]]; then
    for pkg in zsh git-delta atuin duf procs zsh-autosuggestions zsh-syntax-highlighting curl tar jq; do
        pkg_install "$pkg" || true
    done
else
    apt-get update -qq
    for pkg in zsh duf zsh-autosuggestions zsh-syntax-highlighting curl tar jq ripgrep fzf zoxide btop bat fd-find; do
        pkg_install "$pkg" || true
    done
    # Create ~/.local/bin symlinks for Ubuntu's renamed binaries
    mkdir -p "$USER_HOME/.local/bin"
    [[ -x /usr/bin/batcat ]] && ln -sf /usr/bin/batcat "$USER_HOME/.local/bin/bat" && success "bat symlink created (batcat → bat)"
    [[ -x /usr/bin/fdfind ]] && ln -sf /usr/bin/fdfind "$USER_HOME/.local/bin/fd" && success "fd symlink created (fdfind → fd)"
    chown -R "$USER_NAME:$USER_NAME" "$USER_HOME/.local/bin"
fi

# tealdeer: try package manager first, fall back to GitHub binary
if ! command -v tldr &>/dev/null; then
    info "Trying tealdeer from package manager..."
    if ! pkg_install tealdeer 2>/dev/null; then
        info "Package manager failed — installing tealdeer binary from GitHub..."
        TL_URL=$(curl -s https://api.github.com/repos/dbrgn/tealdeer/releases/latest \
            | jq -r '.assets[] | select(.name == "tealdeer-linux-x86_64-musl") | .browser_download_url')
        if [[ -n "$TL_URL" ]]; then
            curl -L "$TL_URL" -o /usr/local/bin/tldr
            chmod +x /usr/local/bin/tldr
            success "tealdeer installed from GitHub binary"
        else
            warn "Could not install tealdeer — skipping"
        fi
    fi
fi

# atuin: not in apt, install via official script on Ubuntu
if [[ "$DISTRO" == "ubuntu" ]] && ! command -v "$USER_HOME/.atuin/bin/atuin" &>/dev/null; then
    step "Installing atuin via official script"
    curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sudo -u "$USER_NAME" sh
    # atuin's installer appends lines to ~/.zshrc — reinstall our config on top
    # (our zshrc already sources ~/.atuin/bin/env so no functionality is lost)
    mkdir -p "$(dirname "$USER_HOME/.zshrc")"
    cp "$SCRIPT_DIR/zshrc" "$USER_HOME/.zshrc"
    chown "$USER_NAME:$USER_NAME" "$USER_HOME/.zshrc"
    success "atuin installed; .zshrc reinstalled (atuin env sourced within zshrc)"
fi

# procs: not in apt, install binary from GitHub zip on Ubuntu
if [[ "$DISTRO" == "ubuntu" ]] && ! command -v procs &>/dev/null; then
    info "Installing procs from GitHub zip..."
    PROCS_URL=$(curl -s https://api.github.com/repos/dalance/procs/releases/latest \
        | jq -r '.assets[] | select(.name | test("procs-.*-x86_64-linux.zip")) | .browser_download_url')
    if [[ -n "$PROCS_URL" ]]; then
        curl -Lo /tmp/procs.zip "$PROCS_URL"
        unzip -o /tmp/procs.zip -d /tmp/procs_extract
        install -m 755 /tmp/procs_extract/procs "$USER_HOME/.local/bin/procs"
        chown "$USER_NAME:$USER_NAME" "$USER_HOME/.local/bin/procs"
        rm -rf /tmp/procs.zip /tmp/procs_extract
        success "procs installed"
    else
        warn "Could not fetch procs release, skipping"
    fi
fi

# git-delta: in apt for 24.04, needs .deb for 22.04
if [[ "$DISTRO" == "ubuntu" ]] && ! command -v delta &>/dev/null; then
    info "Trying git-delta from GitHub .deb..."
    DELTA_URL=$(curl -s https://api.github.com/repos/dandavison/delta/releases/latest \
        | jq -r '.assets[] | select(.name | test("git-delta_.*_amd64.deb")) | .browser_download_url')
    if [[ -n "$DELTA_URL" ]]; then
        curl -Lo /tmp/git-delta.deb "$DELTA_URL"
        dpkg -i /tmp/git-delta.deb
        rm -f /tmp/git-delta.deb
        success "git-delta installed from GitHub"
    else
        warn "Could not install git-delta, skipping"
    fi
fi

step "2. Installing Starship prompt"
curl -sS https://starship.rs/install.sh | sh -s -- --yes
success "Starship installed → $(starship --version)"

step "3. Installing eza (modern ls)"
EZA_URL=$(curl -s https://api.github.com/repos/eza-community/eza/releases/latest \
    | jq -r '.assets[] | select(.name | test("eza_x86_64-unknown-linux-musl.tar.gz")) | .browser_download_url')
if [[ -n "$EZA_URL" ]]; then
    curl -sL "$EZA_URL" | tar xz -C /tmp
    if [[ "$DISTRO" == "ubuntu" ]]; then
        install -m 755 /tmp/eza "$USER_HOME/.local/bin/eza"
        chown "$USER_NAME:$USER_NAME" "$USER_HOME/.local/bin/eza"
    else
        install -m 755 /tmp/eza /usr/local/bin/eza
    fi
    rm -f /tmp/eza
    success "eza installed → $(sudo -u "$USER_NAME" eza --version | head -1)"
else
    warn "Could not fetch eza release URL, skipping"
fi

step "4. Installing lazygit (TUI git client)"
LG_VER=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
    | jq -r '.tag_name' | sed 's/v//')
if [[ -n "$LG_VER" ]]; then
    curl -Lo /tmp/lazygit.tar.gz \
        "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LG_VER}_Linux_${ARCH}.tar.gz"
    tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
    install -m 755 /tmp/lazygit /usr/local/bin/lazygit
    rm -f /tmp/lazygit.tar.gz /tmp/lazygit
    success "lazygit installed → $(lazygit --version)"
else
    warn "Could not fetch lazygit release, skipping"
fi

step "5. Installing dust (modern du)"
DUST_URL=$(curl -s https://api.github.com/repos/bootandy/dust/releases/latest \
    | jq -r '.assets[] | select(.name | test("x86_64-unknown-linux-musl.tar.gz")) | .browser_download_url')
if [[ -n "$DUST_URL" ]]; then
    curl -L "$DUST_URL" | tar xz -C /tmp --wildcards '*/dust'
    DUST_BIN=$(find /tmp -name "dust" -type f | head -1)
    install -m 755 "$DUST_BIN" /usr/local/bin/dust
    rm -rf /tmp/dust-*
    success "dust installed → $(dust --version)"
else
    warn "Could not fetch dust release URL, skipping"
fi

step "6. Setting ZSH as default shell for $USER_NAME"
ZSH_PATH=$(which zsh)
if ! grep -q "$ZSH_PATH" /etc/shells; then
    echo "$ZSH_PATH" >> /etc/shells
fi
chsh -s "$ZSH_PATH" "$USER_NAME"
success "Default shell set to $ZSH_PATH for $USER_NAME"

step "7. Configuring git to use delta for diffs"
sudo -u "$USER_NAME" git config --global core.pager "delta"
sudo -u "$USER_NAME" git config --global interactive.diffFilter "delta --color-only"
sudo -u "$USER_NAME" git config --global delta.navigate true
sudo -u "$USER_NAME" git config --global delta.light false
sudo -u "$USER_NAME" git config --global delta.side-by-side false
sudo -u "$USER_NAME" git config --global delta.line-numbers true
sudo -u "$USER_NAME" git config --global merge.conflictstyle diff3
sudo -u "$USER_NAME" git config --global diff.colorMoved default
success "git configured to use delta"

step "8. Updating tealdeer cache"
sudo -u "$USER_NAME" tldr --update 2>/dev/null || true
success "tldr cache updated"

step "9. Installing config files"
# On Ubuntu, zshrc was already (re)installed after atuin; only install if not yet done
if [[ "$DISTRO" == "fedora" ]]; then
    install_config "$SCRIPT_DIR/zshrc" "$USER_HOME/.zshrc" ".zshrc"
elif [[ ! -s "$USER_HOME/.zshrc" ]] || [[ "$FORCE" == true ]]; then
    # Ubuntu and atuin wasn't installed (already had it) — ensure zshrc is installed
    mkdir -p "$(dirname "$USER_HOME/.zshrc")"
    cp "$SCRIPT_DIR/zshrc" "$USER_HOME/.zshrc"
    chown "$USER_NAME:$USER_NAME" "$USER_HOME/.zshrc"
    success ".zshrc installed → $USER_HOME/.zshrc"
fi
install_config "$SCRIPT_DIR/config/starship.toml" "$USER_HOME/.config/starship.toml"  "starship.toml"

echo ""
echo -e "${GREEN}${BOLD}✓ Setup complete!${RESET}"
echo ""
echo -e "  ${CYAN}Dotfiles repo:${RESET} $SCRIPT_DIR"
echo -e "  ${CYAN}Next steps:${RESET}"
echo -e "  1. ${BOLD}Log out and back in${RESET} (or run: exec zsh)"
echo -e "  2. Your new prompt: ${BOLD}starship${RESET} (Gruvbox Rainbow theme)"
echo -e "  3. Try: ${BOLD}ll${RESET}  ${BOLD}cat README.md${RESET}  ${BOLD}z project${RESET}  ${BOLD}lg${RESET}"
echo -e "  4. Re-run with ${BOLD}--force${RESET} to overwrite existing config files"
echo ""
