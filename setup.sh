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
#   3. プラグインの再インストール案内を表示
#
# アンインストール:
#   setup.sh uninstall

set -euo pipefail

TARGET="$HOME/.claude"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

# --- functions ---

info()  { echo "[INFO]  $*"; }
warn()  { echo "[WARN]  $*" >&2; }
error() { echo "[ERROR] $*" >&2; exit 1; }

backup_existing() {
  if [ -L "$TARGET" ]; then
    local old_link
    old_link="$(readlink "$TARGET")"
    info "$TARGET は既にシンボリックリンク → $old_link"
    if [ "$old_link" = "$SCRIPT_DIR" ]; then
      info "既に正しいリンク先です。何もしません。"
      exit 0
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
  ln -s "$SCRIPT_DIR" "$TARGET"
  info "シンボリックリンク作成: $TARGET → $SCRIPT_DIR"
}

verify() {
  if [ -L "$TARGET" ] && [ "$(readlink "$TARGET")" = "$SCRIPT_DIR" ]; then
    info "検証OK: $TARGET → $SCRIPT_DIR"
  else
    error "検証失敗: シンボリックリンクが正しく作成されていません"
  fi
}

show_post_install() {
  cat <<'EOF'

========================================
  セットアップ完了
========================================

次のステップ:

  1. プラグインの再インストール
     claude plugin install superpowers@claude-plugins-official
     claude plugin install document-skills@anthropic-agent-skills

  2. gh CLI のアップデート（MCP用、v2.67+が必要）
     brew upgrade gh

  3. LaTeX環境のインストール（論文執筆用、任意）
     brew install --cask mactex

  4. 動作確認
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
  latest_backup="$(ls -1d "${TARGET}.old."* 2>/dev/null | sort -r | head -1)"
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

case "${1:-}" in
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
    verify
    show_post_install
    ;;
esac
