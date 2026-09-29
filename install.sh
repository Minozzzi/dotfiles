#!/usr/bin/env zsh
set -e

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "$0")" && pwd)}"

# Garante o Homebrew no PATH caso tenha acabado de ser instalado
if ! command -v brew >/dev/null 2>&1; then
  if [[ -x "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

echo "🔗 1. Fazendo backup de segurança do .zshrc atual..."
if [[ -f "$HOME/.zshrc" && ! -L "$HOME/.zshrc" ]]; then
  cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d%H%M%S)"
fi

echo "🍺 2. Garantindo pacotes do Brewfile..."
brew bundle --file="$DOTFILES_DIR/Brewfile"

echo "📦 3. Configurando Node LTS via FNM, Corepack e @antfu/ni..."
if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env)"
  fnm install --lts
  fnm default lts-latest
  corepack enable 2>/dev/null || true
  npm i -g @antfu/ni 2>/dev/null || true
fi

echo "🔌 4. Garantindo Oh My Zsh e plugins externos..."
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
[[ ! -d "$ZSH_CUSTOM/plugins/fzf-tab" ]] && git clone https://github.com/Aloxaf/fzf-tab "$ZSH_CUSTOM/plugins/fzf-tab"
[[ ! -d "$ZSH_CUSTOM/plugins/you-should-use" ]] && git clone https://github.com/MichaelAquilina/zsh-you-should-use.git "$ZSH_CUSTOM/plugins/you-should-use"
[[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]] && git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
[[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]] && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

echo "🔗 5. Criando Links Simbólicos apontando para $DOTFILES_DIR..."
mkdir -p "$HOME/.config"

[[ -d "$HOME/.config/ghostty" && ! -L "$HOME/.config/ghostty" ]] && rm -rf "$HOME/.config/ghostty"
[[ -d "$HOME/.config/catppuccin-zsh" && ! -L "$HOME/.config/catppuccin-zsh" ]] && rm -rf "$HOME/.config/catppuccin-zsh"
[[ -d "$HOME/.config/delta" && ! -L "$HOME/.config/delta" ]] && rm -rf "$HOME/.config/delta"

ln -sfn "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"
ln -sfn "$DOTFILES_DIR/config/starship.toml" "$HOME/.config/starship.toml"
ln -sfn "$DOTFILES_DIR/config/ghostty" "$HOME/.config/ghostty"
ln -sfn "$DOTFILES_DIR/config/catppuccin-zsh" "$HOME/.config/catppuccin-zsh"
ln -sfn "$DOTFILES_DIR/config/delta" "$HOME/.config/delta"

if [[ -f "$DOTFILES_DIR/vscode/settings.json" ]]; then
  mkdir -p "$HOME/Library/Application Support/Code/User"
  mkdir -p "$HOME/Library/Application Support/Cursor/User"
  ln -sfn "$DOTFILES_DIR/vscode/settings.json" "$HOME/Library/Application Support/Code/User/settings.json"
  ln -sfn "$DOTFILES_DIR/vscode/settings.json" "$HOME/Library/Application Support/Cursor/User/settings.json"
fi

echo "🦇 6. Configurando temas do Bat e Git Delta..."
mkdir -p "$(bat --config-dir)/themes"
curl -fsSL "https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Frappe.tmTheme" -o "$(bat --config-dir)/themes/Catppuccin Frappe.tmTheme"
curl -fsSL "https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Latte.tmTheme" -o "$(bat --config-dir)/themes/Catppuccin Latte.tmTheme"
bat cache --build

git config --global core.pager delta
git config --global interactive.diffFilter "delta --color-only"
git config --global include.path "~/.config/delta/catppuccin.gitconfig"
git config --global delta.navigate true
git config --global delta.side-by-side true
git config --global delta.line-numbers true

git config --global --unset gpg.program 2>/dev/null || true

echo "💤 7. Configurando Lazygit..."
mkdir -p "$HOME/Library/Application Support/lazygit"
cat << 'EOF' > "$HOME/Library/Application Support/lazygit/config.yml"
git:
  paging:
    colorArg: always
    pager: delta --paging=never
gui:
  nerdFontsVersion: "3"
EOF

echo "💻 8. Instalando extensões do Catppuccin para VS Code e Cursor..."
for cli in code cursor; do
  if command -v $cli >/dev/null 2>&1; then
    $cli --install-extension Catppuccin.catppuccin-vsc --force 2>/dev/null || true
    $cli --install-extension Catppuccin.catppuccin-vsc-icons --force 2>/dev/null || true
  fi
done

touch "$HOME/.zshrc.work"

echo "✅ Pronto! Tudo linkado e configurado a partir de $DOTFILES_DIR"
