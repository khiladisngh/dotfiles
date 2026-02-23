# ============================================================
# ~/.zshrc — Modern ZSH Configuration
# ============================================================

# ── History ─────────────────────────────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_VERIFY              # confirm before running history expansion

# ── Options ─────────────────────────────────────────────────
setopt AUTO_CD                  # type directory name to cd into it
setopt CORRECT                  # spell correction
setopt GLOB_DOTS                # include dotfiles in globs
setopt NO_CASE_GLOB             # case-insensitive globbing
setopt INTERACTIVE_COMMENTS     # allow # comments in interactive shell
setopt PUSHD_IGNORE_DUPS        # no duplicate dirs in dir stack
setopt AUTO_PUSHD               # cd pushes to dir stack (use popd / dirs)

# ── Path ────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$HOME/bin:$HOME/.cargo/bin:$PATH"

# ── Completion ──────────────────────────────────────────────
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '%F{yellow}── %d ──%f'
zstyle ':completion:*:warnings' format '%F{red}── no matches ──%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'

# ── Plugins ──────────────────────────────────────────────────
[[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh

[[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#737373,bold"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

# ── Key Bindings ────────────────────────────────────────────
bindkey -e
bindkey '^[[A'   history-search-backward   # Up arrow
bindkey '^[[B'   history-search-forward    # Down arrow
bindkey '^[[H'   beginning-of-line         # Home
bindkey '^[[F'   end-of-line               # End
bindkey '^[[3~'  delete-char               # Delete
bindkey '^[[1;5C' forward-word             # Ctrl+Right
bindkey '^[[1;5D' backward-word            # Ctrl+Left
bindkey '^H'     backward-kill-word        # Ctrl+Backspace

# ── Environment ─────────────────────────────────────────────
export EDITOR="nano"
export VISUAL="$EDITOR"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"    # colorized man pages via bat
export BAT_THEME="gruvbox-dark"
export PAGER="bat --paging=always"

# ============================================================
# EZA — Modern ls replacement
# ============================================================
if command -v eza &>/dev/null; then
    # ── Basic listing ─────────────────────────────────────
    alias ls='eza --icons=always --group-directories-first --color=always'
    alias la='eza --icons=always --group-directories-first --color=always -a'
    alias l='eza --icons=always --group-directories-first --color=always -1'   # one per line
    alias l1='eza --icons=always -1 -a'                                         # one per line, all

    # ── Long/detail views ─────────────────────────────────
    alias ll='eza --icons=always --group-directories-first --color=always -la --git --time-style=relative'
    alias lla='eza --icons=always --group-directories-first --color=always -la --git --time-style=relative -a'
    alias llm='eza --icons=always -la --git --sort=modified --time-style=relative'   # sorted by modified time
    alias lls='eza --icons=always -la --git --sort=size'                              # sorted by size
    alias llx='eza --icons=always -la --git --sort=extension'                         # sorted by extension

    # ── Tree views ────────────────────────────────────────
    alias lt='eza --icons=always --tree --level=2 --group-directories-first'
    alias lt2='eza --icons=always --tree --level=2 --group-directories-first'
    alias lt3='eza --icons=always --tree --level=3 --group-directories-first'
    alias lt4='eza --icons=always --tree --level=4 --group-directories-first'
    alias lta='eza --icons=always --tree --level=2 --group-directories-first -a'      # tree, show hidden
    alias ltl='eza --icons=always --tree --level=2 --group-directories-first -la --git'  # tree + details
    alias lts='eza --icons=always --tree --level=2 --sort=size -la'                   # tree sorted by size

    # ── Filtered views ────────────────────────────────────
    alias lf='eza --icons=always --color=always -la --git | fzf'                      # fuzzy search listing
    alias ldir='eza --icons=always --only-dirs --group-directories-first'              # directories only
    alias lfiles='eza --icons=always --only-files'                                     # files only
    alias lgit='eza --icons=always -la --git --git-ignore'                             # respect .gitignore
else
    # Fallback if eza not installed
    alias ls='ls --color=auto --group-directories-first'
    alias la='ls -A'
    alias ll='ls -lahF'
    alias lt='tree -C -L 2'
fi

# ============================================================
# BAT — Modern cat replacement
# ============================================================
if command -v bat &>/dev/null; then
    alias cat='bat --paging=never'
    alias catp='bat'                                  # with paging
    alias batl='bat -l'                               # specify language: batl python file.txt
    alias batp='bat --plain --paging=never'           # no decorations (pure content)
    alias diff='bat --diff'                           # colorized diff
    # preview a file with syntax highlight
    preview() { bat --color=always --style=numbers,changes "$@" | less -R }
fi

# ============================================================
# FD — Modern find replacement
# ============================================================
if command -v fd &>/dev/null; then
    alias find='fd'
    alias fda='fd -H'                                 # include hidden
    alias fdf='fd -t f'                               # files only
    alias fdd='fd -t d'                               # directories only
    alias fdx='fd -t x'                               # executables only
fi

# ============================================================
# RIPGREP — Modern grep replacement
# ============================================================
if command -v rg &>/dev/null; then
    alias grep='rg'
    alias rgi='rg -i'                                 # case insensitive
    alias rgh='rg --hidden'                           # include hidden files
    alias rgf='rg -l'                                 # filenames only
    alias rgt='rg -t'                                 # by type: rgt py "pattern"
fi

# ============================================================
# BTOP — Modern top/htop replacement
# ============================================================
if command -v btop &>/dev/null; then
    alias top='btop'
    alias htop='btop'
    alias cpu='btop'
fi

# ============================================================
# DUST — Modern du replacement
# ============================================================
if command -v dust &>/dev/null; then
    alias du='dust'
    alias duh='dust -d 1'                             # current dir depth 1
    alias dua='dust -d 1 -a'                          # all files
fi

# ============================================================
# DUF — Modern df replacement
# ============================================================
if command -v duf &>/dev/null; then
    alias df='duf'
    alias dfa='duf --all'
fi

# ============================================================
# PROCS — Modern ps replacement
# ============================================================
if command -v procs &>/dev/null; then
    alias ps='procs'
    alias pst='procs --tree'                          # process tree
    alias psg='procs'                                 # search: psg nginx
fi

# ============================================================
# TLDR / TEALDEER — Quick man pages
# ============================================================
if command -v tldr &>/dev/null; then
    alias help='tldr'
    alias h='tldr'
fi

# ============================================================
# FZF — Fuzzy finder
# ============================================================
if command -v fzf &>/dev/null; then
    [[ -f /usr/share/fzf/shell/key-bindings.zsh ]] && \
        source /usr/share/fzf/shell/key-bindings.zsh

    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
    export FZF_DEFAULT_OPTS='
        --height=50%
        --layout=reverse
        --border=rounded
        --info=inline
        --color=fg:#cdd6f4,hl:#f38ba8,fg+:#cdd6f4,bg+:#313244,hl+:#f38ba8
        --color=info:#cba6ac,prompt:#cba6ac,pointer:#f5e0dc,marker:#f5e0dc,spinner:#f5e0dc,header:#f38ba8
        --preview="bat --color=always --line-range=:80 {} 2>/dev/null || eza --icons --tree --level=2 --color=always {} 2>/dev/null"
        --preview-window=right:55%:wrap
        --bind=ctrl-/:toggle-preview
        --bind=ctrl-u:preview-page-up
        --bind=ctrl-d:preview-page-down
    '
fi

# ============================================================
# ZOXIDE — Smarter cd
# ============================================================
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh --cmd cd)"
    alias j='z'               # jump to frecent dir
    alias ji='zi'             # interactive jump with fzf
    alias jl='zoxide query --list'   # list known dirs
fi

# ============================================================
# ATUIN — Magical shell history
# ============================================================
if command -v atuin &>/dev/null; then
    eval "$(atuin init zsh)"
fi

# ============================================================
# GIT — Comprehensive aliases
# ============================================================

# ── Status & Info ────────────────────────────────────────────
alias g='git'
alias gs='git status -sb'                                        # short status with branch
alias gss='git status'                                           # full status
alias gl='git log --oneline --graph --decorate --color'          # compact log
alias gla='git log --oneline --graph --decorate --color --all'   # all branches
alias glp='git log --graph --pretty=format:"%C(bold blue)%h%Creset -%C(bold yellow)%d%Creset %s %C(bold green)(%cr) %C(bold cyan)<%an>%Creset" --abbrev-commit --all'
alias gls='git log --stat --oneline'                             # with file stats
alias glf='git log --follow -p --'                               # history of a file: glf file.txt
alias gshow='git show --stat'                                    # show last commit details
alias gwho='git shortlog -sn'                                    # contributors by commit count

# ── Staging & Committing ─────────────────────────────────────
alias ga='git add'
alias gaa='git add -A'                                           # add all
alias gap='git add -p'                                           # interactive/patch add
alias gau='git add -u'                                           # add tracked modified files
alias gc='git commit -m'                                         # commit with message: gc "msg"
alias gca='git commit --amend'                                   # amend last commit
alias gcae='git commit --amend --no-edit'                        # amend without editing msg
alias gcane='git commit --amend --no-edit'
alias gcm='git commit'                                           # open editor for commit msg
alias gcs='git commit -S -m'                                     # signed commit
alias gfix='git commit --fixup'                                  # fixup for a commit: gfix <sha>

# ── Branching ────────────────────────────────────────────────
alias gb='git branch'
alias gba='git branch -a'                                        # all branches (local+remote)
alias gbr='git branch -r'                                        # remote branches
alias gbd='git branch -d'                                        # delete branch (safe)
alias gbD='git branch -D'                                        # force delete branch
alias gbm='git branch -m'                                        # rename branch: gbm old new
alias gco='git checkout'
alias gcob='git checkout -b'                                     # create + switch branch
alias gsw='git switch'                                           # modern branch switching
alias gswc='git switch -c'                                       # create + switch
alias gswd='git switch -'                                        # switch to previous branch

# ── Remote & Sync ────────────────────────────────────────────
alias gf='git fetch'
alias gfa='git fetch --all --prune'                              # fetch all, remove dead remotes
alias gp='git push'
alias gpf='git push --force-with-lease'                          # safer force push
alias gpu='git push -u origin HEAD'                              # push + set upstream
alias gpl='git pull'
alias gplr='git pull --rebase'                                   # pull with rebase
alias grem='git remote -v'                                       # show remotes
alias gtrack='git branch --set-upstream-to'                      # set tracking: gtrack origin/main

# ── Diff & Compare ───────────────────────────────────────────
alias gd='git diff'
alias gdc='git diff --cached'                                    # diff staged changes
alias gdn='git diff --name-only'                                 # filenames only
alias gdw='git diff --word-diff'                                 # word-level diff
alias gdt='git difftool'

# ── Stash ────────────────────────────────────────────────────
alias gst='git stash'
alias gsta='git stash apply'
alias gstp='git stash pop'
alias gstl='git stash list'
alias gstd='git stash drop'
alias gsts='git stash show -p'                                   # show stash contents

# ── Rebase & Merge ───────────────────────────────────────────
alias grb='git rebase'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbi='git rebase -i'                                       # interactive: grbi HEAD~3
alias gm='git merge'
alias gmff='git merge --ff-only'
alias gmnff='git merge --no-ff'

# ── Utility ──────────────────────────────────────────────────
alias gclean='git clean -fd'                                     # remove untracked files+dirs
alias greset='git reset HEAD~1'                                  # undo last commit (keep changes)
alias gresetH='git reset --hard HEAD~1'                          # undo last commit (discard changes)
alias gtag='git tag'
alias gtags='git tag -l'
alias gcl='git clone'
alias gcl1='git clone --depth=1'                                 # shallow clone
alias gignore='git update-index --assume-unchanged'              # locally ignore a file
alias gunignore='git update-index --no-assume-unchanged'
alias gwip='git add -A && git commit -m "WIP: work in progress"'
alias gunwip='git reset HEAD~1'                                  # undo wip commit

# ── Lazygit ──────────────────────────────────────────────────
if command -v lazygit &>/dev/null; then
    alias lg='lazygit'
fi

# ============================================================
# DNF — Package management
# ============================================================
alias dni='sudo dnf install -y'
alias dnr='sudo dnf remove -y'
alias dnu='sudo dnf upgrade -y'
alias dns='dnf search'
alias dninfo='dnf info'
alias dnl='dnf list installed'
alias dnlu='dnf list updates'
alias dnc='sudo dnf autoremove -y && sudo dnf clean all'        # cleanup

# ============================================================
# Navigation
# ============================================================
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ~='cd ~'
alias -- -='cd -'                                                # go to previous directory

# Quick dirs
alias dl='cd ~/Downloads'
alias dt='cd ~/Desktop'
alias doc='cd ~/Documents'
alias proj='cd ~/Projects 2>/dev/null || cd ~/projects 2>/dev/null || echo "No ~/Projects dir"'
alias cfg='cd ~/.config'

# ============================================================
# System
# ============================================================
alias mkdir='mkdir -pv'
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -Iv'
alias ln='ln -iv'
alias chmod='chmod -v'
alias chown='chown -v'

alias path='echo $PATH | tr ":" "\n" | nl'                      # pretty PATH
alias ports='ss -tulpn'
alias myip='curl -s ifconfig.me && echo'
alias localip='hostname -I | awk "{print \$1}"'
alias reload='exec zsh && echo "zsh reloaded"'
alias zshrc='${EDITOR} ~/.zshrc'
alias starshiprc='${EDITOR} ~/.config/starship.toml'
alias hosts='sudo ${EDITOR} /etc/hosts'

# ============================================================
# Functions — Complex operations
# ============================================================

# Extract any archive
extract() {
    if [[ ! -f "$1" ]]; then echo "'$1' is not a file"; return 1; fi
    case "$1" in
        *.tar.bz2|*.tbz2) tar xjf "$1"         ;;
        *.tar.gz|*.tgz)   tar xzf "$1"         ;;
        *.tar.xz)          tar xJf "$1"         ;;
        *.tar.zst)         tar --zstd -xf "$1"  ;;
        *.tar)             tar xf "$1"           ;;
        *.bz2)             bunzip2 "$1"          ;;
        *.gz)              gunzip "$1"           ;;
        *.zip)             unzip "$1"            ;;
        *.rar)             unrar x "$1"          ;;
        *.7z)              7z x "$1"             ;;
        *.zst)             zstd -d "$1"          ;;
        *)  echo "Don't know how to extract '$1'" ;;
    esac
}

# mkdir + cd in one
mkcd() { mkdir -p "$1" && cd "$1" }

# Clone a repo and immediately cd into it
gcld() {
    git clone "$1" "${2:-.}" && cd "${2:-$(basename "$1" .git)}"
}

# fzf + cd — fuzzy jump to any directory
fcd() {
    local dir
    dir=$(fd --type d --hidden --exclude .git . "${1:-.}" | fzf \
        --preview='eza --icons --tree --level=2 --color=always {}' \
        --preview-window=right:50%) && cd "$dir"
}

# fzf + open file in editor
fe() {
    local file
    file=$(fd --type f --hidden --exclude .git | fzf \
        --preview='bat --color=always --line-range=:80 {}' \
        --preview-window=right:60%) && ${EDITOR} "$file"
}

# fzf + kill process
fkill() {
    local pid
    pid=$(procs 2>/dev/null | fzf --header-lines=1 | awk '{print $1}') || return
    echo "Killing PID: $pid"
    kill -${1:-9} "$pid"
}

# fzf + git checkout branch
gbf() {
    local branch
    branch=$(git branch -a | fzf --preview 'git log --oneline --graph --color {} | head -20' | sed 's/remotes\/origin\///') \
        && git checkout "$branch"
}

# fzf + git log — checkout any commit
glogf() {
    local commit
    commit=$(git log --oneline --color | fzf --ansi \
        --preview 'git show --color {1} | head -60' \
        --preview-window=right:60%) \
        && git checkout "$(echo "$commit" | awk '{print $1}')"
}

# Pretty git log with rich info
glog() {
    git log --graph \
        --pretty=format:'%C(bold blue)%h%Creset%C(bold yellow)%d%Creset %s %C(dim white)— %an%Creset %C(bold green)(%cr)%Creset' \
        --abbrev-commit \
        --date=relative \
        "$@" | bat --plain --language=gitlog --color=always 2>/dev/null || \
    git log --graph \
        --pretty=format:'%C(bold blue)%h%Creset%C(bold yellow)%d%Creset %s %C(dim white)— %an%Creset %C(bold green)(%cr)%Creset' \
        --abbrev-commit --date=relative "$@"
}

# Show directory size sorted
usage() {
    if command -v dust &>/dev/null; then
        dust -d "${1:-1}" .
    else
        du -sh -- * | sort -rh | head -20
    fi
}

# Quick http server
serve() {
    local port="${1:-8000}"
    echo "Serving on http://localhost:$port"
    python3 -m http.server "$port"
}

# Show colors in terminal
colors() {
    for i in {0..255}; do
        printf "\x1b[38;5;${i}m%-5d" "$i"
        (( (i+1) % 16 == 0 )) && echo
    done
}

# Create a temp directory and cd into it
tmpcd() {
    local dir
    dir=$(mktemp -d)
    echo "Created: $dir"
    cd "$dir"
}

# Copy file contents to clipboard (Wayland/X11)
clip() {
    if command -v wl-copy &>/dev/null; then
        cat "$1" | wl-copy && echo "Copied to clipboard (Wayland)"
    elif command -v xclip &>/dev/null; then
        cat "$1" | xclip -selection clipboard && echo "Copied to clipboard (X11)"
    else
        echo "Install wl-clipboard or xclip"
    fi
}

# git add -A + commit with message
gac() {
    git add -A && git commit -m "$*"
}

# git add -A + commit + push
gacp() {
    git add -A && git commit -m "$*" && git push
}

# Create a new git branch and push it immediately
gnb() {
    git checkout -b "$1"
    git push -u origin "$1"
}

# Show what changed in git since a date or ref
gchanges() {
    git log --since="${1:-1 week ago}" --oneline --author="$(git config user.email)"
}

# eza + bat combined — list and preview selected file
lp() {
    local file
    file=$(eza --icons -la --color=always "${1:-.}" | fzf --ansi \
        --preview='bat --color=always --line-range=:100 {-1} 2>/dev/null || eza --icons --tree --color=always {-1}' \
        --preview-window=right:55% | awk '{print $NF}')
    [[ -n "$file" ]] && bat "$file" 2>/dev/null || eza --icons --tree "$file"
}

# ── Starship Prompt (must be last) ──────────────────────────
if command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
fi
