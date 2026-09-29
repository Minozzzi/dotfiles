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

echo "🤖 6. Configurando IA, Coding Harnesses (OMP, Claude, Gemini/Antigravity, Copilot, OpenCode) e Skills..."
mkdir -p "$HOME/.omp/agent"
mkdir -p "$HOME/.claude"
mkdir -p "$HOME/.gemini/config"
mkdir -p "$HOME/.agents"
mkdir -p "$HOME/.copilot"
mkdir -p "$HOME/.config/opencode"

# 6.1 Unificando e linkando Skills compartilhadas entre todos os harnesses
for skill_target in \
  "$HOME/.agents/skills" \
  "$HOME/.gemini/config/skills" \
  "$HOME/.gemini/skills" \
  "$HOME/.claude/skills" \
  "$HOME/.omp/skills" \
  "$HOME/.omp/agent/skills" \
  "$HOME/.omp/agent/managed-skills" \
  "$HOME/.copilot/skills" \
  "$HOME/.config/opencode/instructions"; do
  if [[ -d "$skill_target" && ! -L "$skill_target" ]]; then
    echo "  📦 Fazendo backup de diretório existente de skills em $skill_target..."
    mv "$skill_target" "${skill_target}.backup.$(date +%Y%m%d%H%M%S)"
  fi
  mkdir -p "$(dirname "$skill_target")"
  ln -sfn "$DOTFILES_DIR/config/skills" "$skill_target"
done

# 6.2 OMP (Oh-My-Pi / coding agent)
ln -sfn "$DOTFILES_DIR/config/omp/config.yml" "$HOME/.omp/agent/config.yml"
ln -sfn "$DOTFILES_DIR/config/omp/models.yml" "$HOME/.omp/agent/models.yml"
ln -sfn "$DOTFILES_DIR/config/omp/mcp.json" "$HOME/.omp/agent/mcp.json"

# 6.3 Claude Code
ln -sfn "$DOTFILES_DIR/config/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"

# 6.4 Antigravity / Gemini
if [[ -d "$HOME/.gemini/config/plugins" && ! -L "$HOME/.gemini/config/plugins" ]]; then
  mv "$HOME/.gemini/config/plugins" "$HOME/.gemini/config/plugins.backup.$(date +%Y%m%d%H%M%S)"
fi
ln -sfn "$DOTFILES_DIR/config/gemini/config.json" "$HOME/.gemini/config/config.json"
ln -sfn "$DOTFILES_DIR/config/gemini/mcp_config.json" "$HOME/.gemini/config/mcp_config.json"
ln -sfn "$DOTFILES_DIR/config/gemini/settings.json" "$HOME/.gemini/settings.json"
ln -sfn "$DOTFILES_DIR/config/gemini/AGENTS.md" "$HOME/.gemini/config/AGENTS.md"
ln -sfn "$DOTFILES_DIR/config/gemini/GEMINI.md" "$HOME/GEMINI.md"
ln -sfn "$DOTFILES_DIR/config/gemini/plugins" "$HOME/.gemini/config/plugins"

# 6.5 OpenCode
if [[ -d "$HOME/.config/opencode/commands" && ! -L "$HOME/.config/opencode/commands" ]]; then
  mv "$HOME/.config/opencode/commands" "$HOME/.config/opencode/commands.backup.$(date +%Y%m%d%H%M%S)"
fi
if [[ -d "$HOME/.config/opencode/plugins" && ! -L "$HOME/.config/opencode/plugins" ]]; then
  mv "$HOME/.config/opencode/plugins" "$HOME/.config/opencode/plugins.backup.$(date +%Y%m%d%H%M%S)"
fi
ln -sfn "$DOTFILES_DIR/config/opencode/opencode.jsonc" "$HOME/.config/opencode/opencode.jsonc"
ln -sfn "$DOTFILES_DIR/config/opencode/commands" "$HOME/.config/opencode/commands"
ln -sfn "$DOTFILES_DIR/config/opencode/plugins" "$HOME/.config/opencode/plugins"
ln -sfn "$DOTFILES_DIR/config/opencode/package.json" "$HOME/.config/opencode/package.json"

# 6.6 Copilot CLI
ln -sfn "$DOTFILES_DIR/config/copilot/settings.json" "$HOME/.copilot/settings.json"
ln -sfn "$DOTFILES_DIR/config/copilot/mcp-config.json" "$HOME/.copilot/mcp-config.json"

# 6.7 Regras Globais Compartilhadas (Cursor, IDEs, Harnesses)
ln -sfn "$DOTFILES_DIR/config/ai-rules/.cursorrules" "$HOME/.cursorrules"

echo "🦇 7. Configurando temas do Bat e Git Delta..."
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

echo "💤 8. Configurando Lazygit..."
mkdir -p "$HOME/Library/Application Support/lazygit"
cat << 'EOF' > "$HOME/Library/Application Support/lazygit/config.yml"
git:
  paging:
    colorArg: always
    pager: delta --paging=never
gui:
  nerdFontsVersion: "3"
EOF

echo "💻 9. Instalando extensões do Catppuccin para VS Code e Cursor..."
for cli in code cursor; do
  if command -v $cli >/dev/null 2>&1; then
    $cli --install-extension Catppuccin.catppuccin-vsc --force 2>/dev/null || true
    $cli --install-extension Catppuccin.catppuccin-vsc-icons --force 2>/dev/null || true
  fi
done

if [[ ! -f "$HOME/.zshrc.work" ]]; then
  cat << 'EOF' > "$HOME/.zshrc.work"
# Chaves e Tokens sensíveis para MCP servers (Github, Gitlab, ClickUp, Figma, Postman, etc.)
# export GITHUB_PERSONAL_ACCESS_TOKEN=""
# export GITLAB_PERSONAL_ACCESS_TOKEN=""
# export GITLAB_TOKEN=""
# export CLICKUP_API_KEY=""
# export CLICKUP_API_TOKEN=""
# export CLICKUP_TOKEN=""
# export FIGMA_PERSONAL_ACCESS_TOKEN=""
# export FIGMA_ACCESS_TOKEN=""
# export POSTMAN_API_KEY=""
# export DD_API_KEY=""
# export DD_APP_KEY=""
# export BRAVE_API_KEY=""
EOF
fi

echo "✅ Pronto! Tudo linkado e configurado a partir de $DOTFILES_DIR"

