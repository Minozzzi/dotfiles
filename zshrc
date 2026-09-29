export PATH="$HOME/.local/bin:$HOME/.local/share/fnm:$PATH"
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""

# --- Detecção Automática: Catppuccin Frappé (Dark) / Latte (Light) ---
is_dark_mode() {
  [[ "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" == "Dark" ]]
}

apply_catppuccin_theme() {
  if is_dark_mode; then
    CATPPUCCIN_FLAVOR="frappe"
    export BAT_THEME="Catppuccin Frappe"
    export DELTA_FEATURES="+catppuccin-frappe"
    export FZF_DEFAULT_OPTS=" \
    --color=bg+:#414559,bg:#303446,spinner:#f2d5cf,hl:#e78284 \
    --color=fg:#c6d0f5,header:#e78284,info:#ca9ee6,pointer:#f2d5cf \
    --color=marker:#babbf1,fg+:#c6d0f5,prompt:#ca9ee6,hl+:#e78284 \
    --color=selected-bg:#51576d \
    --prompt='❯ ' --pointer='▶' --marker='✓'"
  else
    CATPPUCCIN_FLAVOR="latte"
    export BAT_THEME="Catppuccin Latte"
    export DELTA_FEATURES="+catppuccin-latte"
    export FZF_DEFAULT_OPTS=" \
    --color=bg+:#ccd0da,bg:#eff1f5,spinner:#dc8a78,hl:#d20f39 \
    --color=fg:#4c4f69,header:#d20f39,info:#8839ef,pointer:#dc8a78 \
    --color=marker:#7287fd,fg+:#4c4f69,prompt:#8839ef,hl+:#d20f39 \
    --color=selected-bg:#bcc0cc \
    --prompt='❯ ' --pointer='▶' --marker='✓'"
  fi

  # 1. Aplica o tema no zsh-syntax-highlighting
  [[ -f ~/.config/catppuccin-zsh/${CATPPUCCIN_FLAVOR}.zsh ]] && source ~/.config/catppuccin-zsh/${CATPPUCCIN_FLAVOR}.zsh

  # 2. Gera o starship ativo em ~/.cache para não sujar o Git nem quebrar o Symlink
  if [[ -f ~/.config/starship.toml ]]; then
    mkdir -p ~/.cache/starship
    sed "s/^palette = .*/palette = \"catppuccin_${CATPPUCCIN_FLAVOR}\"/" ~/.config/starship.toml > ~/.cache/starship/starship.toml
    export STARSHIP_CONFIG="$HOME/.cache/starship/starship.toml"
  fi
}

apply_catppuccin_theme

# --- Plugins do Zsh ---
plugins=(
  git
  sudo
  extract
  copypath
  copybuffer
  fzf-tab
  you-should-use
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# --- Previews do fzf-tab com Eza e Bat ---
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons $realpath'
zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat --color=always --line-range :50 $realpath 2>/dev/null || eza -1 --color=always --icons $realpath 2>/dev/null'
zstyle ':fzf-tab:*' fzf-bindings 'tab:accept'

# --- Histórico e Atalhos ---
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
bindkey '^ ' autosuggest-accept

# --- Aliases ---
if command -v eza &> /dev/null; then
  alias ls="eza --icons"
  alias ll="eza -lh --icons --git"
  alias la="eza -lah --icons --git"
  alias tree="eza --tree --icons"
fi

if command -v bat &> /dev/null; then
  alias cat="bat --paging=never"
fi

alias ..="cd .."
alias ...="cd ../.."
alias reload="source ~/.zshrc"
alias lg="lazygit"
alias dots="cd ~/projects/dotfiles"

# --- Sincroniza Light/Dark na aba aberta ---
_sync_theme_on_prompt() {
  local expected="frappe"
  is_dark_mode || expected="latte"
  if [[ "$expected" != "$CATPPUCCIN_FLAVOR" ]]; then
    apply_catppuccin_theme
  fi
}
precmd_functions+=(_sync_theme_on_prompt)

# --- Inicialização ---
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"
command -v fnm >/dev/null 2>&1 && eval "$(fnm env --use-on-cd)"
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# --- Isolamento para variáveis exclusivas do Mac da empresa ---
[[ -f ~/.zshrc.work ]] && source ~/.zshrc.work
