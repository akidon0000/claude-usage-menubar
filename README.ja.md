<p align="center">
  <img src="assets/banner.svg" alt="Claude Usage" width="100%"/>
</p>

<h1 align="center">Claude Usage Menubar</h1>

<p align="center">
  <strong>Claude Code の「使い方」をメニューバーから一目で。</strong><br/>
  ローカルの Claude Code 利用ログを読み込み、Skill・MCP・サブエージェント・プロンプトの利用回数を表示する、軽量な SwiftUI 製メニューバーアプリです。
</p>

<p align="center">
  <img alt="Platform" src="https://img.shields.io/badge/platform-macOS%2014%2B-1B1B1F?style=flat-square&logo=apple"/>
  <img alt="Language" src="https://img.shields.io/badge/Swift-6.0-F05138?style=flat-square&logo=swift&logoColor=white"/>
  <img alt="UI" src="https://img.shields.io/badge/SwiftUI-NSStatusItem-D97757?style=flat-square"/>
  <img alt="License" src="https://img.shields.io/badge/License-MIT-2E2018?style=flat-square"/>
  <img alt="PRs" src="https://img.shields.io/badge/PRs-welcome-E8927C?style=flat-square"/>
  <a href="https://github.com/akidon0000/claude-usage-menubar/actions/workflows/ci.yml"><img alt="CI" src="https://github.com/akidon0000/claude-usage-menubar/actions/workflows/ci.yml/badge.svg"/></a>
</p>

<p align="center">
  <a href="README.md">English</a> ·
  <a href="README.ja.md">日本語</a>
</p>

---

<p align="center">
  <img src="assets/screenshot.svg" alt="ポップオーバーのスクリーンショット" width="560"/>
</p>

## ✨ なぜ作ったか

Claude Code は普段から多くの利用シグナルを蓄積しています — どの Skill をよく使うか、どの MCP サーバーを叩いているか、サブエージェントをどれくらい呼ぶか、何回プロンプトを送ったか。ですがそのデータは `~/.claude/usage/` 配下の JSON に溜まったままです。**Claude Usage Menubar** はそれを可視化します。メニューバーに常駐してそれらのファイルを読み込み、いつでも確認できるポップオーバーに集計表示します。サーバーもテレメトリもネットワークも無し — すべて Mac の中で完結します。

## 🚀 特長

- 📊 **メニューバー常駐** — 棒グラフアイコンのみ、Dock を汚さない（`LSUIElement = YES`）。
- 🔢 **合計を一目で** — Skills / MCP / Agents / Prompts を 4 枚のサマリーカードで表示。
- 🗂 **ジャンル別に集約** — `work` / `personal` / `side-project` / その他。タップで絞り込み。
- 📦 **リポジトリ別の内訳** — 各リポジトリを開くと Skill / MCP / Agent / Prompt の回数に加え、Top Skills・Top MCP ツールを表示。
- 🔒 **100% ローカル** — `~/.claude/usage/<org>/<repo>.json` を直接読むだけ。データは外に出ません。
- 🔄 **ワンクリック再読み込み** — いつでもログを読み直せます。

## 🧰 動作環境

- macOS **14.0** Sonoma 以降
- Xcode **16+** / Swift **6.0** ツールチェイン（ビルド用）
- `~/.claude/usage/` 配下の Claude Code 利用ログ（これが可視化対象）

## 📦 インストール

### 方法 1: スクリプトでビルド & インストール（おすすめ）

```bash
git clone https://github.com/akidon0000/claude-usage-menubar.git
cd claude-usage-menubar

./build.sh
```

`build.sh` はリリースビルドを行い、`Claude Usage.app` を `/Applications` にパッケージし、アドホック署名して起動します。

### 方法 2: ソースから実行

```bash
swift run -c release
```

> [!NOTE]
> このアプリは**アドホック署名**（`codesign --sign -`）です。初回起動時に「開発元を確認できない」と警告が出ることがあります。アプリを右クリックして **開く** を選ぶか、**システム設定 → プライバシーとセキュリティ** から許可してください。

## 🖱 使い方

1. メニューバーの棒グラフアイコンをクリック。
2. 上段に累計が表示されます: **Skills** / **MCP** / **Agents** / **Prompts**。
3. **ジャンル**行（`work`, `personal` …）をタップすると、下のリポジトリ一覧を絞り込めます。
4. **リポジトリ**行をタップすると展開され、カテゴリ別の回数・Top Skills・Top MCP ツールが見られます。
5. **↻** でログを読み直し、**⊗** で終了。

## 🗂 データソース

アプリは以下のレイアウトを走査し、見つかった `*.json` をすべてデコードします:

```
~/.claude/usage/
└── <org>/
    └── <repo>.json
```

各ファイルは `_repo`・`_org`・`_genre`、`tools` マップ（キーは `Skill:` / `MCP:` / `Subagent:` で始まる）、`session` ブロック（`Prompt`・`InstructionLoad`）を持つ想定です。欠けたフィールドは無難なデフォルトにフォールバックするため、部分的なファイルでもクラッシュしません。

## 🏗 アーキテクチャ

```
ClaudeUsageMenubar/Sources/
├── App.swift          # @main、AppDelegate、NSStatusItem + NSPopover の配線
├── PopoverView.swift  # SwiftUI のポップオーバー: サマリーカード・ジャンル行・リポジトリ行
└── UsageStore.swift   # ObservableObject: ~/.claude/usage を走査し JSON をデコード・集計
```

- `UsageStore` が単一の信頼できる情報源（SSOT）。JSON を読み、`RepoUsage` / `GenreSummary` を構築して publish します。
- `PopoverView` は純粋な表示層で、ストアに駆動されます。
- `AppDelegate` がステータスアイテムとポップオーバーのライフサイクルを保持。アプリはアクセサリ（Dock アイコン無し）として動作します。

## 🤝 コントリビュート

PR 歓迎です！開発環境・コーディングスタイル・PR チェックリストは [CONTRIBUTING.md](CONTRIBUTING.md) を参照してください。

アイデアの一例:

- 本物の `.icns` アプリアイコン。
- ログイン時起動トグル。
- 期間フィルタ（今日 / 今週 / 全期間）。
- 編集メトリクス（追加 / 削除行数）の可視化 — データはすでにデコード済み。

## 📄 ライセンス

[MIT](LICENSE) © akidon0000
