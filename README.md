# dotfiles

guchi の dotfiles。新マシンセットアップ用。

## セットアップ

```bash
git clone https://github.com/zenntouyou-yabai/dotfiles ~/dotfiles
bash ~/dotfiles/install.sh
```

## 管理ファイル

| ファイル | リンク先 | 説明 |
|---------|---------|------|
| `.zshrc` | `~/.zshrc` | zsh 設定（NVM lazy load / エイリアス / cdev関数） |
| `.gitconfig` | `~/.gitconfig` | Git ユーザー設定・エイリアス |
| `.gitignore_global` | `~/.gitignore_global` | 全プロジェクト共通の git 除外設定 |
| `.tmux.conf` | `~/.tmux.conf` | tmux キーバインド・見た目設定 |
| `config/ghostty/config` | `~/.config/ghostty/config` | Ghostty ターミナル設定 |
| `config/gh/config.yml` | `~/.config/gh/config.yml` | GitHub CLI 設定 |

## 次のステップ

```bash
# tmux 設定を即時反映
tmux source ~/.tmux.conf

# zsh 設定を即時反映
source ~/.zshrc

# NVM インストール（未インストールの場合）
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/HEAD/install.sh | bash
```
