#!/usr/bin/env bash
# dotfiles インストールスクリプト
# 新しいマシンでの初回セットアップ用
# 使い方: bash ~/dotfiles/install.sh
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔧 dotfiles セットアップ開始..."
echo "   ソース: $DOTFILES_DIR"
echo ""

# ホームディレクトリへのシンボリックリンク作成
link_home() {
    local file="$1"
    local src="$DOTFILES_DIR/$file"
    local dst="$HOME/$file"

    mkdir -p "$(dirname "$dst")"

    if [[ -f "$dst" && ! -L "$dst" ]]; then
        echo "  📦 バックアップ: ~/$file → ~/${file}.bak"
        mv "$dst" "${dst}.bak"
    fi

    ln -sf "$src" "$dst"
    echo "  ✅ ~/$file"
}

# ~/.config/ 以下のシンボリックリンク作成
link_config() {
    local file="$1"
    local src="$DOTFILES_DIR/config/$file"
    local dst="$HOME/.config/$file"

    mkdir -p "$(dirname "$dst")"

    if [[ -f "$dst" && ! -L "$dst" ]]; then
        echo "  📦 バックアップ: ~/.config/$file → ~/.config/${file}.bak"
        mv "$dst" "${dst}.bak"
    fi

    ln -sf "$src" "$dst"
    echo "  ✅ ~/.config/$file"
}

echo "[ ホームディレクトリ ]"
link_home ".zshrc"
link_home ".gitconfig"
link_home ".gitignore_global"
link_home ".tmux.conf"

echo ""
echo "[ ~/.config/ ]"
link_config "ghostty/config"
link_config "gh/config.yml"

echo ""
echo "✨ 完了！新しいターミナルを開くと .zshrc が反映されます。"
echo ""
echo "次のステップ:"
echo "  1. tmux: tmux source ~/.tmux.conf"
echo "  2. zsh:  source ~/.zshrc"
echo "  3. nvm:  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/HEAD/install.sh | bash"
