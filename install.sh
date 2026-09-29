#!/usr/bin/env zsh
set -e

DOTFILES_DIR="$HOME/projects/dotfiles"

echo "🔗 1. Fazendo backup de segurança do .zshrc atual..."
if [[ -f "$HOME/.zshrc" && ! -L "$HOME/.zshrc" ]]; then
  cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d%H%M%S)"
fi

echo "🍺 2. Garantindo pacotes do Brewfile..."
brew bundle --file="$DOTFILES_DIR/Brewfile"

echo "🔌 3. Garantindo Oh My Zsh e plugins externos..."
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
[[ ! -d "$ZSH_CUSTOM/plugins/fzf-tab" ]] && git clone https://github.com/Aloxaf/fzf-tab "$ZSH_CUSTOM/plugins/fzf-tab"
[[ ! -d "$ZSH_CUSTOM/plugins/you-should-use" ]] && git clone https://github.com/MichaelAquilina/zsh-you-should-use.git "$ZSH_CUSTOM/plugins/you-should-use"
[[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]] && git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
[[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]] && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

echo "🔗 4. Criando Links Simbólicos apontando para ~/projects/dotfiles..."
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

echo "🦇 5. Configurando temas do Bat e Git Delta..."
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

touch "$HOME/.zshrc.work"

echo "✅ Pronto! Tudo linkado em ~/projects/dotfiles"
