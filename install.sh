#!/usr/bin/env bash
# dotfiles インストールスクリプト
# 新しいマシンでの初回セットアップ用
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔧 dotfiles セットアップ開始..."

# シンボリックリンクを作成する関数
link() {
    local src="$DOTFILES_DIR/$1"
    local dst="$HOME/$1"

    if [[ -f "$dst" && ! -L "$dst" ]]; then
        echo "  📦 バックアップ: $dst → $dst.bak"
        mv "$dst" "$dst.bak"
    fi

    ln -sf "$src" "$dst"
    echo "  ✅ リンク: ~/$1 → $src"
}

link ".zshrc"

echo ""
echo "✨ 完了！新しいターミナルを開くと反映されます。"
