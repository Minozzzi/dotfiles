#!/usr/bin/env zsh
# ==============================================================================
# 🚀 SETUP COMPLETO DO ZERO - MACOS (GHOSTTY + ZSH + STARSHIP + CATPPUCCIN)
# ==============================================================================
set -e

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "$0")" && pwd)}"

echo "⚡ 1. Garantindo Homebrew..."
if ! command -v brew >/dev/null 2>&1; then
  if [[ -x "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  else
    echo "🍺 Instalando Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install.sh)"
    [[ -x "/opt/homebrew/bin/brew" ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
    [[ -x "/usr/local/bin/brew" ]] && eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

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

echo "🚀 3. Executando instalação e linking dos dotfiles..."
"$DOTFILES_DIR/install.sh"

echo "✨ Setup concluído com sucesso!"
