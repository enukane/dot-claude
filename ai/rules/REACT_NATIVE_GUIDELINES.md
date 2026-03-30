# React Native コード規約ガイドライン

> このガイドラインは、baby-log プロジェクト（Expo + React Native + TypeScript）における
> コーディング規約をまとめたものです。実装時は必ずこのファイルを参照してください。

---

## 外部スキル参照（必須）

**React Native / Expo のベストプラクティスは以下のスキルを優先参照してください：**
~/.claude/skills/vercel-react-native-skills/SKILL.md       # クイックリファレンス・優先度一覧
~/.claude/skills/vercel-react-native-skills/AGENTS.md      # 全ルール展開（詳細版）
~/.claude/skills/vercel-react-native-skills/rules/         # 個別ルールファイル

実装時は以下の優先度でルールを適用してください：

| 優先度 | カテゴリ | キーワード |
|--------|----------|------------|
| 1 | リストパフォーマンス | `list-performance-*` |
| 2 | アニメーション | `animation-*` |
| 3 | ナビゲーション | `navigation-*` |
| 4 | UI パターン | `ui-*` |
| 5 | 状態管理 | `react-state-*` |
| 6 | レンダリング | `rendering-*` |

---

## 1. ファイル・ディレクトリ規約

### ファイル命名
- コンポーネントファイル: `PascalCase.tsx`（例: `BabyCard.tsx`）
- フック: `use-kebab-case.ts`（例: `use-baby-log.ts`）
- ユーティリティ・定数: `kebab-case.ts`（例: `date-utils.ts`）
- プラットフォーム分岐: `.ios.tsx` / `.web.ts` サフィックスで上書き

### 配置ルール
src/
├ screens/     # 画面コンポーネント（ナビゲーションと1対1）
├ components/  # 再利用可能なUIコンポーネント
│  └ ui/       # 低レベルプリミティブ（Button, Text, Icon など）
├ hooks/       # カスタム Hooks（use- プレフィックス必須）
├ constants/   # 定数・テーマ（theme.ts など）
├ utils/       # 純粋関数ユーティリティ
├ types/       # 共有型定義
└ atoms/       # グローバル状態（Zustand / Jotai）