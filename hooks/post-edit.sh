#!/usr/bin/env bash
# Post-Edit/Write Hook — ファイル編集後の自動検証
# 用途: settings.json の PostToolUse (Write|Edit) から呼び出される
# 入力: stdin に JSON (tool_name, tool_input, tool_response)
# 出力: JSON (hookSpecificOutput) または空

set -euo pipefail

# stdin から hook 入力を読む
input=$(cat)

# ファイルパスを抽出
file_path=$(echo "$input" | jq -r '.tool_response.filePath // .tool_input.file_path // empty')

if [ -z "$file_path" ]; then
  exit 0
fi

extension="${file_path##*.}"

case "$extension" in
  json)
    # JSON 構文検証
    if ! jq . "$file_path" > /dev/null 2>&1; then
      cat <<HOOK_JSON
{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"WARNING: $file_path has invalid JSON syntax. Please fix."}}
HOOK_JSON
    fi
    ;;

  tex)
    # LaTeX 構文チェック (chktex がインストール済みの場合のみ)
    if command -v chktex > /dev/null 2>&1; then
      warnings=$(chktex -q "$file_path" 2>&1 | head -5)
      if [ -n "$warnings" ]; then
        # 改行を \\n にエスケープ
        escaped=$(echo "$warnings" | sed ':a;N;$!ba;s/\n/\\n/g' | sed 's/"/\\"/g')
        cat <<HOOK_JSON
{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"chktex warnings:\\n$escaped"}}
HOOK_JSON
      fi
    fi
    ;;
esac
