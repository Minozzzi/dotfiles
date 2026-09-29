#!/usr/bin/env zsh
# ==============================================================================
# 🚀 SETUP COMPLETO DO ZERO - MACOS (GHOSTTY + ZSH + STARSHIP + CATPPUCCIN)
# ==============================================================================
# Este script contém toda a construção do ambiente passo a passo:
# - Ferramentas CLI em Rust (Starship, Eza, Bat, Zoxide, FNM, Delta, FZF, Lazygit)
# - Emulador de terminal Ghostty + Fonte FiraCode Nerd Font
# - Troca automática Light/Dark (Catppuccin Latte / Catppuccin Frappé)
# - Oh My Zsh + 4 Plugins externos (fzf-tab, you-should-use, autosuggestions, syntax)
# - Configurações do VS Code / Cursor + Ajustes de performance do macOS
# - Estrutura de Dotfiles com Links Simbólicos em ~/projects/dotfiles
# ==============================================================================

set -e

DOTFILES_DIR="$HOME/projects/dotfiles"
mkdir -p "$DOTFILES_DIR/config/"{ghostty,catppuccin-zsh,delta}
mkdir -p "$DOTFILES_DIR/vscode"

echo "🍺 1. Instalando pacotes CLI, Ghostty e FiraCode Nerd Font via Homebrew..."
brew install starship fzf eza bat zoxide fnm git-delta lazygit
brew install --cask ghostty font-fira-code-nerd-font

echo "⚡ 2. Aplicando ajustes de performance do teclado e Finder no macOS..."
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
killall Finder 2>/dev/null || true

echo "🔌 3. Instalando Oh My Zsh e os 4 plugins externos..."
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
[[ ! -d "$ZSH_CUSTOM/plugins/fzf-tab" ]] && git clone https://github.com/Aloxaf/fzf-tab "$ZSH_CUSTOM/plugins/fzf-tab"
[[ ! -d "$ZSH_CUSTOM/plugins/you-should-use" ]] && git clone https://github.com/MichaelAquilina/zsh-you-should-use.git "$ZSH_CUSTOM/plugins/you-should-use"
[[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]] && git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
[[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]] && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

echo "🎨 4. Baixando temas Catppuccin (Frappé e Latte) para Zsh, Bat e Git Delta..."
# Zsh Syntax Highlighting
curl -fsSL https://raw.githubusercontent.com/catppuccin/zsh-syntax-highlighting/main/themes/catppuccin_frappe-zsh-syntax-highlighting.zsh -o "$DOTFILES_DIR/config/catppuccin-zsh/frappe.zsh"
curl -fsSL https://raw.githubusercontent.com/catppuccin/zsh-syntax-highlighting/main/themes/catppuccin_latte-zsh-syntax-highlighting.zsh -o "$DOTFILES_DIR/config/catppuccin-zsh/latte.zsh"

# Git Delta
curl -fsSL https://raw.githubusercontent.com/catppuccin/delta/main/catppuccin.gitconfig -o "$DOTFILES_DIR/config/delta/catppuccin.gitconfig"

# Bat
mkdir -p "$(bat --config-dir)/themes"
curl -fsSL "https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Frappe.tmTheme" -o "$(bat --config-dir)/themes/Catppuccin Frappe.tmTheme"
curl -fsSL "https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Latte.tmTheme" -o "$(bat --config-dir)/themes/Catppuccin Latte.tmTheme"
bat cache --build

echo "👻 5. Gerando configuração do Ghostty..."
cat << 'EOF' > "$DOTFILES_DIR/config/ghostty/config"
# Fonte (com ligaduras ativas por padrão)
font-family = FiraCode Nerd Font
font-size = 14
font-thicken = true

# Catppuccin embutido no Ghostty (muda sozinho com o macOS)
theme = light:Catppuccin Latte,dark:Catppuccin Frappe

# Ergonomia no macOS
macos-option-as-alt = true
macos-titlebar-style = tabs
window-padding-x = 12
window-padding-y = 10
window-save-state = always
copy-on-select = clipboard
shell-integration = zsh

# Atalhos de divisão de tela (Splits)
keybind = cmd+d=new_split:right
keybind = cmd+shift+d=new_split:down
keybind = cmd+opt+left=goto_split:left
keybind = cmd+opt+right=goto_split:right
keybind = cmd+opt+up=goto_split:up
keybind = cmd+opt+down=goto_split:down
keybind = cmd+shift+enter=toggle_split_zoom
EOF

echo "🚀 6. Gerando configuração do Starship (Frappé + Latte)..."
cat << 'EOF' > "$DOTFILES_DIR/config/starship.toml"
"$schema" = 'https://starship.rs/config-schema.json'

palette = "catppuccin_frappe"

[character]
success_symbol = "[❯](bold green)"
error_symbol = "[❯](bold red)"
vimcmd_symbol = "[❮](bold subtext1)"

[directory]
truncation_length = 4
style = "bold lavender"

[git_branch]
symbol = " "
style = "bold mauve"

[git_status]
style = "bold peach"

[nodejs]
symbol = " "
style = "bold green"

[cmd_duration]
min_time = 500
style = "bold yellow"

# Paleta Escura: Catppuccin Frappé
[palettes.catppuccin_frappe]
rosewater = "#f2d5cf"
flamingo = "#eebebe"
pink = "#f4b8e4"
mauve = "#ca9ee6"
red = "#e78284"
maroon = "#ea999c"
peach = "#ef9f76"
yellow = "#e5c890"
green = "#a6d189"
teal = "#81c8be"
sky = "#99d1db"
sapphire = "#85c1dc"
blue = "#8caaee"
lavender = "#babbf1"
text = "#c6d0f5"
subtext1 = "#b5bfe2"
subtext0 = "#a5adce"
overlay2 = "#949cbb"
overlay1 = "#838ba7"
overlay0 = "#737994"
surface2 = "#626880"
surface1 = "#51576d"
surface0 = "#414559"
base = "#303446"
mantle = "#292c3c"
crust = "#232634"

# Paleta Clara: Catppuccin Latte
[palettes.catppuccin_latte]
rosewater = "#dc8a78"
flamingo = "#dd7878"
pink = "#ea76cb"
mauve = "#8839ef"
red = "#d20f39"
maroon = "#e64553"
peach = "#fe640b"
yellow = "#df8e1d"
green = "#40a02b"
teal = "#179299"
sky = "#04a5e5"
sapphire = "#209fb5"
blue = "#1e66f5"
lavender = "#7287fd"
text = "#4c4f69"
subtext1 = "#5c5f77"
subtext0 = "#6c6f85"
overlay2 = "#7c7f93"
overlay1 = "#8c8fa1"
overlay0 = "#9ca0b0"
surface2 = "#acb0be"
surface1 = "#bcc0cc"
surface0 = "#ccd0da"
base = "#eff1f5"
mantle = "#e6e9ef"
crust = "#dce0e8"
EOF

echo "🐚 7. Gerando arquivo .zshrc completo..."
cat << 'EOF' > "$DOTFILES_DIR/zshrc"
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
EOF

echo "💤 8. Configurando Lazygit e Git Delta..."
mkdir -p "$HOME/Library/Application Support/lazygit"
cat << 'EOF' > "$HOME/Library/Application Support/lazygit/config.yml"
git:
  paging:
    colorArg: always
    pager: delta --paging=never
gui:
  nerdFontsVersion: "3"
EOF

git config --global core.pager delta
git config --global interactive.diffFilter "delta --color-only"
git config --global include.path "~/.config/delta/catppuccin.gitconfig"
git config --global delta.navigate true
git config --global delta.side-by-side true
git config --global delta.line-numbers true
git config --global --unset gpg.program 2>/dev/null || true

echo "📦 9. Configurando Node LTS via FNM, Corepack e @antfu/ni..."
eval "$(fnm env)"
fnm install --lts
fnm default lts-latest
corepack enable
npm i -g @antfu/ni

echo "💻 10. Configurando VS Code / Cursor (FiraCode + Catppuccin Auto)..."
cat << 'EOF' > "$DOTFILES_DIR/vscode/settings.json"
{
  "window.autoDetectColorScheme": true,
  "workbench.preferredDarkColorTheme": "Catppuccin Frappé",
  "workbench.preferredLightColorTheme": "Catppuccin Latte",
  "workbench.iconTheme": "catppuccin-frappe",
  "editor.fontFamily": "'FiraCode Nerd Font', 'Fira Code', Menlo, monospace",
  "editor.fontSize": 14,
  "editor.lineHeight": 1.6,
  "editor.fontLigatures": true,
  "terminal.integrated.fontFamily": "'FiraCode Nerd Font'",
  "terminal.integrated.fontSize": 13,
  "terminal.integrated.fontLigatures.enabled": true,
  "terminal.integrated.minimumContrastRatio": 1,
  "terminal.integrated.macOptionIsMeta": true,
  "catppuccin.accentColor": "mauve",
  "catppuccin.italicKeywords": true,
  "catppuccin.italicComments": true,
  "catppuccin.bracketMode": "rainbow"
}
EOF

for cli in code cursor; do
  if command -v $cli >/dev/null 2>&1; then
    $cli --install-extension Catppuccin.catppuccin-vsc || true
    $cli --install-extension Catppuccin.catppuccin-vsc-icons || true
  fi
done

echo "🔗 11. Criando Links Simbólicos e atualizando Brewfile..."
"$DOTFILES_DIR/install.sh"
brew bundle dump --file="$DOTFILES_DIR/Brewfile" --force

echo "✅ Setup completo do zero finalizado!"
