#!/bin/bash
# ============================================================
# Modern Shell Setup — Fedora 43
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

# Install a dnf package, warn on failure instead of aborting
dnf_install() {
    local pkg="$1"
    if dnf install -y "$pkg" &>/dev/null; then
        success "$pkg installed"
    else
        warn "$pkg failed via DNF, will try fallback if available"
        return 1
    fi
}

# ── Must run as root ─────────────────────────────────────────
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}Run with sudo:${RESET} sudo bash install.sh"
    exit 1
fi

step "1. Installing packages via DNF (one by one to isolate failures)"
for pkg in zsh git-delta atuin duf procs zsh-autosuggestions zsh-syntax-highlighting curl tar jq; do
    dnf_install "$pkg" || true
done

# tealdeer: try DNF first, fall back to GitHub binary
if ! command -v tldr &>/dev/null; then
    info "Trying tealdeer from DNF..."
    if ! dnf_install tealdeer 2>/dev/null; then
        info "DNF failed — installing tealdeer binary from GitHub..."
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

step "2. Installing Starship prompt"
curl -sS https://starship.rs/install.sh | sh -s -- --yes
success "Starship installed → $(starship --version)"

step "3. Installing eza (modern ls)"
EZA_URL=$(curl -s https://api.github.com/repos/eza-community/eza/releases/latest \
    | jq -r '.assets[] | select(.name | test("eza_x86_64-unknown-linux-musl.tar.gz")) | .browser_download_url')
if [[ -n "$EZA_URL" ]]; then
    curl -L "$EZA_URL" | tar xz -C /tmp eza
    install -m 755 /tmp/eza /usr/local/bin/eza
    rm -f /tmp/eza
    success "eza installed → $(eza --version | head -1)"
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
install_config "$SCRIPT_DIR/zshrc"               "$USER_HOME/.zshrc"                  ".zshrc"
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
