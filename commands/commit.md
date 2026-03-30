---
allowed-tools: Bash, Read, Grep, Glob
---

# 構造化コミット

`ai/rules/GIT_WORKFLOW.md` の Conventional Commits 規約に従ってコミットを作成する。

## 手順

1. `git status` と `git diff --staged` を実行して変更内容を把握する
2. ステージングされていない変更がある場合、ユーザーに確認してから `git add` する
3. 変更内容から以下を推論する:
   - **type**: feat, fix, refactor, docs, test, chore, style, perf, ci, build のいずれか
   - **scope**: 変更されたモジュール/ディレクトリから推論（任意）
   - **subject**: 変更の要約（50文字以内、英語、命令形、小文字始まり、ピリオドなし）
4. `$ARGUMENTS` が指定されている場合はそれをヒントとしてメッセージに反映する
5. body には「なぜ」この変更が必要かを簡潔に記載する
6. コミットメッセージをユーザーに提示し、確認を取る
7. 確認後にコミットを実行する

## フォーマット

```
<type>(<scope>): <subject>

<body>
```

## 注意
- 1コミット = 1つの論理的変更
- secrets（.env, credentials等）をコミットしない
- `git add -A` は使わない。変更ファイルを個別に指定する
