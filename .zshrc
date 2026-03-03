# Added by Antigravity
export PATH="/Users/sekiguchiyuki/.antigravity/antigravity/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
# ─── NVM レイジーロード ───────────────────────────────────────────────────
# 戦略:
#   - node/npm/pnpm 等を初めて呼ぶまで NVM を読み込まない（起動 ~0.55s 削減）
#   - .nvmrc があるディレクトリに cd したら自動で nvm use（chpwd フック）
#   - 起動ディレクトリに .nvmrc があれば最初のプロンプト前に一度だけチェック
#   - _NVM_LOADED フラグで二重ロードを防止
_NVM_LOADED=0

_nvm_lazy_load() {
  if [[ $_NVM_LOADED -eq 0 ]]; then
    _NVM_LOADED=1
    unset -f node npm npx nvm yarn pnpm corepack 2>/dev/null
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  fi
}

# .nvmrc を現在〜ルートまで探してバージョンを切り替え
_nvm_auto_use() {
  local dir="$PWD"
  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/.nvmrc" ]]; then
      _nvm_lazy_load
      nvm use --silent 2>/dev/null
      return
    fi
    dir="${dir:h}"
  done
}

# cd するたびに .nvmrc をチェック
autoload -U add-zsh-hook
add-zsh-hook chpwd _nvm_auto_use

# 起動ディレクトリの .nvmrc を最初のプロンプト前に 1 回だけチェック
_nvm_initial_check() {
  add-zsh-hook -d precmd _nvm_initial_check
  _nvm_auto_use
}
add-zsh-hook precmd _nvm_initial_check

# コマンドスタブ（初回呼び出し時に NVM をロード）
node()     { _nvm_lazy_load; node     "$@"; }
npm()      { _nvm_lazy_load; npm      "$@"; }
npx()      { _nvm_lazy_load; npx      "$@"; }
nvm()      { _nvm_lazy_load; nvm      "$@"; }
yarn()     { _nvm_lazy_load; yarn     "$@"; }
pnpm()     { _nvm_lazy_load; pnpm     "$@"; }
corepack() { _nvm_lazy_load; corepack "$@"; }
# ────────────────────────────────────────────────────────────────────────

# Claude Code parallel launcher
alias clp='~/.claude/scripts/claude-parallel.sh'
export PATH="$HOME/.local/bin:$PATH"

# ─── Claude Code モデルプロファイル (Codex CLI profiles インスパイア) ────
# cc     → デフォルト (Sonnet: バランス型)
# ccf    → Fast/Cheap (Haiku: 軽作業・調査・要約)
# cco    → Power (Opus: 複雑設計・難問・アーキテクチャ)
alias cc='claude'
alias ccf='claude --model claude-haiku-4-5-20251001'
alias cco='claude --model claude-opus-4-6'
# ────────────────────────────────────────────────────────────────────────

# 機密情報（~/.secrets から読み込み）
[ -f ~/.secrets ] && source ~/.secrets

alias workspace="~/.claude/scripts/workspace.sh"
# tmux workspace は明示的に `workspace` コマンドで起動（自動アタッチ廃止）

# ─── cmux: 開発レイアウト一発起動 ────────────────────────────────────────
# 使い方: cdev [ディレクトリ]  例: cdev ~/project/myapp
# レイアウト:
#   ┌──────────────┬──────────────────────┐
#   │ Yazi（上）    │                      │
#   ├──────────────│   Claude Code        │
#   │ Terminal（下）│                      │
#   └──────────────┴──────────────────────┘
cdev() {
  local dir="${1:-$(pwd)}"
  local ws="$CMUX_WORKSPACE_ID"
  local yazi_surface="$CMUX_SURFACE_ID"

  # cmux 環境チェック
  if [[ -z "$ws" || -z "$yazi_surface" ]]; then
    echo "⚠️  cmux ターミナル内で実行してください (CMUX_WORKSPACE_ID が未設定)"
    return 1
  fi

  # 右にClaude Code用ペインを作成
  local claude_out
  claude_out=$(cmux new-split right --workspace "$ws" --surface "$yazi_surface" 2>/dev/null)
  local claude_surface
  claude_surface=$(echo "$claude_out" | grep -oE 'surface:[0-9]+' | head -1)

  # 左側(Yazi)の下にTerminal用ペインを作成
  local term_out
  term_out=$(cmux new-split down --workspace "$ws" --surface "$yazi_surface" 2>/dev/null)
  local term_surface
  term_surface=$(echo "$term_out" | grep -oE 'surface:[0-9]+' | head -1)

  # プロンプトが出るまで待ってからコマンドを送るヘルパー
  _cdev_send() {
    local surface="$1" cmd="$2"
    local i=0
    while [[ $i -lt 30 ]]; do
      local screen
      screen=$(cmux read-screen --workspace "$ws" --surface "$surface" --lines 3 2>/dev/null)
      if echo "$screen" | grep -qE '❯|>>>|\$\s|%\s|sekiguchi'; then
        cmux send    --workspace "$ws" --surface "$surface" "$cmd" > /dev/null 2>&1
        cmux send-key --workspace "$ws" --surface "$surface" enter  > /dev/null 2>&1
        return
      fi
      sleep 0.5
      ((i++))
    done
    echo "⚠️  タイムアウト: surface $surface のプロンプトが出現しませんでした"
  }

  _cdev_send "$yazi_surface"   "cd $dir && yazi ."
  _cdev_send "$claude_surface" "cd $dir && claude"
  _cdev_send "$term_surface"   "cd $dir"
}
# ────────────────────────────────────────────────────────────────────────
