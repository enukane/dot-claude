#!/usr/bin/env bash
# setup.sh — dot-claude セットアップスクリプト
#
# 用途:
#   git clone git@github.com:enukane/dot-claude.git ~/dot-claude
#   ~/dot-claude/setup.sh
#
# 動作:
#   1. 既存の ~/.claude を ~/.claude.old.YYYYMMDD-HHMMSS に退避
#   2. クローン先ディレクトリへのシンボリックリンクを ~/.claude に作成
#   3. プラグインのマーケットプレイス登録 & インストール
#
# サブコマンド:
#   setup.sh              — フルセットアップ（退避 + リンク + プラグイン）
#   setup.sh plugins      — プラグインのみ再インストール
#   setup.sh uninstall    — シンボリックリンク解除 & 退避の復元
#
# 対応OS: macOS, Linux

set -euo pipefail

TARGET="$HOME/.claude"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

# --- functions ---

info()  { echo "[INFO]  $*"; }
warn()  { echo "[WARN]  $*" >&2; }
error() { echo "[ERROR] $*" >&2; exit 1; }

detect_os() {
  case "$(uname -s)" in
    Darwin) OS="macos" ;;
    Linux)  OS="linux" ;;
    *)      OS="unknown" ;;
  esac
  info "OS: $OS ($(uname -s) $(uname -m))"
}

check_prerequisites() {
  local missing=()

  if ! command -v claude > /dev/null 2>&1; then
    missing+=("claude (Claude Code CLI)")
  fi
  if ! command -v git > /dev/null 2>&1; then
    missing+=("git")
  fi
  if ! command -v jq > /dev/null 2>&1; then
    missing+=("jq")
  fi

  if [ ${#missing[@]} -gt 0 ]; then
    error "以下のコマンドが見つかりません: ${missing[*]}"
  fi
}

backup_existing() {
  if [ -L "$TARGET" ]; then
    local old_link
    old_link="$(readlink "$TARGET")"
    info "$TARGET は既にシンボリックリンク → $old_link"
    if [ "$old_link" = "$SCRIPT_DIR" ]; then
      info "既に正しいリンク先です。スキップします。"
      return 0
    fi
    info "既存のシンボリックリンクを削除します"
    rm "$TARGET"
  elif [ -d "$TARGET" ]; then
    local backup="${TARGET}.old.${TIMESTAMP}"
    info "既存の $TARGET を $backup に退避します"
    mv "$TARGET" "$backup"
    info "退避完了: $backup"
  elif [ -e "$TARGET" ]; then
    error "$TARGET が予期しないファイル種別です（ディレクトリでもリンクでもない）"
  fi
}

create_symlink() {
  if [ -L "$TARGET" ] && [ "$(readlink "$TARGET")" = "$SCRIPT_DIR" ]; then
    info "シンボリックリンクは既に存在します"
    return 0
  fi
  ln -s "$SCRIPT_DIR" "$TARGET"
  info "シンボリックリンク作成: $TARGET → $SCRIPT_DIR"
}

verify_symlink() {
  if [ -L "$TARGET" ] && [ "$(readlink "$TARGET")" = "$SCRIPT_DIR" ]; then
    info "検証OK: $TARGET → $SCRIPT_DIR"
  else
    error "検証失敗: シンボリックリンクが正しく作成されていません"
  fi
}

install_plugins() {
  info "プラグインのセットアップを開始します"

  # マーケットプレイス登録（既に存在する場合はスキップ）
  local marketplaces
  marketplaces="$(claude plugin marketplace list 2>&1 || true)"

  if ! echo "$marketplaces" | grep -q "claude-plugins-official"; then
    info "マーケットプレイス登録: claude-plugins-official"
    claude plugin marketplace add anthropics/claude-plugins-official || warn "claude-plugins-official の登録に失敗しました"
  else
    info "マーケットプレイス claude-plugins-official は登録済み"
  fi

  if ! echo "$marketplaces" | grep -q "anthropic-agent-skills"; then
    info "マーケットプレイス登録: anthropic-agent-skills"
    claude plugin marketplace add https://github.com/anthropics/skills.git || warn "anthropic-agent-skills の登録に失敗しました"
  else
    info "マーケットプレイス anthropic-agent-skills は登録済み"
  fi

  # プラグインインストール
  info "プラグインインストール: superpowers"
  claude plugin install superpowers@claude-plugins-official || warn "superpowers のインストールに失敗しました"

  info "プラグインインストール: document-skills"
  claude plugin install document-skills@anthropic-agent-skills || warn "document-skills のインストールに失敗しました"

  info "プラグインセットアップ完了"
}

show_post_install() {
  cat <<EOF

========================================
  セットアップ完了
========================================

インストール済み:
  - シンボリックリンク: $TARGET → $SCRIPT_DIR
  - プラグイン: superpowers, document-skills

EOF

  # OS別の追加手順
  if [ "$OS" = "macos" ]; then
    cat <<'EOF'
追加の推奨手順 (macOS):

  1. gh CLI のアップデート（GitHub MCP用、v2.67+が必要）
     brew upgrade gh

  2. LaTeX環境のインストール（論文執筆用、任意）
     brew install --cask mactex

EOF
  elif [ "$OS" = "linux" ]; then
    cat <<'EOF'
追加の推奨手順 (Linux):

  1. gh CLI のインストール（GitHub MCP用、v2.67+が必要）
     https://github.com/cli/cli/blob/trunk/docs/install_linux.md

  2. LaTeX環境のインストール（論文執筆用、任意）
     sudo apt install texlive-full  # Debian/Ubuntu
     sudo dnf install texlive-scheme-full  # Fedora/RHEL

EOF
  fi

  cat <<'EOF'
動作確認:
  claude
  # セッション内で /commit, /review, /paper が使えることを確認

EOF
}

do_uninstall() {
  if [ ! -L "$TARGET" ]; then
    error "$TARGET はシンボリックリンクではありません。手動で対処してください。"
  fi

  local link_dest
  link_dest="$(readlink "$TARGET")"
  info "シンボリックリンクを削除: $TARGET → $link_dest"
  rm "$TARGET"

  # 最新の .claude.old.* があれば復元提案
  local latest_backup
  latest_backup="$(ls -1d "${TARGET}.old."* 2>/dev/null | sort -r | head -1 || true)"
  if [ -n "$latest_backup" ]; then
    info "退避ディレクトリが見つかりました: $latest_backup"
    read -rp "復元しますか？ [y/N] " ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
      mv "$latest_backup" "$TARGET"
      info "復元完了: $TARGET"
    else
      info "復元をスキップしました。手動で mv してください。"
    fi
  else
    warn "退避ディレクトリが見つかりません。必要に応じて mkdir ~/.claude してください。"
  fi
}

# --- main ---

detect_os
check_prerequisites

case "${1:-}" in
  plugins)
    install_plugins
    ;;
  uninstall)
    do_uninstall
    ;;
  *)
    info "dot-claude セットアップ開始"
    info "クローン先: $SCRIPT_DIR"
    info "リンク先:   $TARGET"
    echo ""
    backup_existing
    create_symlink
    verify_symlink
    install_plugins
    show_post_install
    ;;
esac
