# LaTeX 論文執筆ワークフロー for Claude Code

> Claude Codeが論文（LaTeX）の執筆・編集・ビルドを支援する際に従うべきガイドラインです。
> `CLAUDE.md` から参照してください。

---

## 1. 基本方針

- **原文を尊重する**: 著者の文体・表現を維持し、勝手にリライトしない
- **変更は最小限に**: 指示された箇所のみ修正する。周辺の「改善」は提案に留める
- **LaTeXコマンドを壊さない**: `\cite{}`, `\ref{}`, `\label{}` 等の整合性を常に保つ
- **コンパイル可能性を維持**: 編集後にビルドが通ることを確認する

---

## 2. ファイル構成の規約

### 推奨ディレクトリ構造
```
paper-project/
├── main.tex           # メイン文書（\input で章を読み込む）
├── sections/          # 章ごとの .tex ファイル（大規模論文の場合）
│   ├── introduction.tex
│   ├── related-work.tex
│   ├── method.tex
│   ├── evaluation.tex
│   └── conclusion.tex
├── figures/           # 図（PDF, EPS, PNG）
├── tables/            # 表の .tex ファイル（複雑な表の場合）
├── refs.bib           # 参考文献
├── Makefile           # ビルド自動化（任意）
├── latexmkrc          # latexmk設定（任意）
└── CLAUDE.md          # プロジェクト固有の指示
```

### 既存プロジェクトではそのまま従う
- 上記はあくまで推奨。既存の構成を勝手に変更しない
- 単一 `main.tex` のプロジェクトは無理に分割しない

---

## 3. 執筆ルール

### 文章スタイル
- 学術論文の慣習に従う（受動態の適切な使用、正確な用語）
- 略語は初出時にフルスペルを記載: `Internet of Things (IoT)`
- 数値には単位を付ける: `10\,ms`, `5\,Gbps`
- 図表への言及: `Fig.~\ref{fig:xxx}`, `Table~\ref{tab:xxx}`

### ラベル命名規約
```latex
\label{sec:introduction}    % セクション
\label{fig:system-overview}  % 図
\label{tab:comparison}       % 表
\label{eq:latency-model}     % 数式
\label{alg:scheduling}       % アルゴリズム
```

### BibTeX
- キーは `著者名年タイトルキーワード` 形式: `kaneko2025vuotemps`
- 不要なフィールド（abstract, keywords, file等）は除去
- DOI がある場合は含める
- 引用の整合性: 本文中の `\cite{}` と `.bib` エントリの対応を確認

---

## 4. ビルドコマンド

### latexmk（推奨）
```bash
# PDF生成（pdflatex）
latexmk -pdf main.tex

# PDF生成（lualatex — Unicode対応が必要な場合）
latexmk -lualatex main.tex

# dvipdfmx 経由（日本語 or 既存プロジェクト）
latexmk -pdfdvi main.tex

# クリーンアップ
latexmk -c main.tex
```

### 手動ビルド（latexmkが使えない場合）
```bash
pdflatex main.tex && bibtex main && pdflatex main.tex && pdflatex main.tex
```

### ビルド検証チェックリスト
1. コンパイルエラーがないこと
2. `Undefined reference` 警告がないこと
3. `Citation undefined` 警告がないこと
4. Overfull/Underfull hbox の重大なものがないこと

---

## 5. 学会テンプレート別の注意

### IEEE (IEEEtran)
- `\documentclass[conference]{IEEEtran}` — conference paper
- `\documentclass[journal]{IEEEtran}` — journal paper
- ページ制限に注意（conference: 通常6ページ）
- `\IEEEoverridecommandlockouts` は資金情報の脚注用

### IEICE
- テンプレート固有のクラスファイルに従う
- 和文と英文で書式が異なる

### ACM
- `\documentclass[sigconf]{acmart}` 等
- ACM固有のメタデータ（CCS概念、keywords）を忘れない

---

## 6. Claude Code での作業フロー

### 新規論文の場合
1. テンプレートとクラスファイルを確認
2. 全体構成（章立て）をプランモードで設計
3. セクションごとに執筆 → ビルド検証のサイクル

### 既存論文の修正（査読対応等）
1. まず全体を読んで内容を把握する
2. 査読コメントをリスト化し、対応方針を立てる
3. 修正箇所ごとに diff が明確になるよう編集
4. Response letter のドラフトも支援可能

### 図表の操作
- 図は `figures/` に配置し、相対パスで参照
- Claude Code は図の内容を読み取れる（PNG, PDF）
- グラフ生成スクリプト（Python/matplotlib等）も支援可能

---

## 7. TeXLive インストール（未インストールの場合）

```bash
# macOS — MacTeX (フルインストール, ~4GB)
brew install --cask mactex

# または最小インストール
brew install --cask basictex
# 必要なパッケージを追加
sudo tlmgr update --self
sudo tlmgr install latexmk collection-langjapanese IEEEtran
```
