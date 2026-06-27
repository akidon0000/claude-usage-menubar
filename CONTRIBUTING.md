# Contributing to Claude Usage Menubar

Thanks for your interest! This is a small, personal-use macOS menu-bar app, but PRs that make it better for everyone are very welcome. This guide is intentionally short — keep it in mind, but don't sweat the small stuff.

[English](#en) · [日本語](#ja)

---

<a id="en"></a>

## English

### Ground rules

- **Be kind.** This project follows the spirit of the [Contributor Covenant](https://www.contributor-covenant.org/). Be respectful in issues, PRs, and reviews.
- **One topic per PR.** Smaller, focused PRs get merged faster than sprawling ones.
- **Discuss before big changes.** For features that change UX or architecture, open an issue first so we can align before you spend time coding.

### Dev setup

```bash
git clone https://github.com/akidon0000/claude-usage-menubar.git
cd claude-usage-menubar

swift build            # debug build
swift run -c release   # run the app from source
./build.sh             # package + install Claude Usage.app to /Applications
```

The app reads `~/.claude/usage/<org>/<repo>.json`. If you don't have real logs, drop a sample JSON there to exercise the UI.

### Coding style

- SwiftUI + Swift Concurrency. UI-touching state lives on `@MainActor`.
- Keep `UsageStore` the single source of truth for parsing and aggregation; `PopoverView` stays pure presentation.
- Don't add dependencies unless there's a strong reason — staying dependency-free keeps the app trivial to build.
- Match the existing file layout under [`ClaudeUsageMenubar/Sources/`](ClaudeUsageMenubar/Sources/).

### Commit messages

- Subject line: imperative, < 72 chars. e.g. `Add launch-at-login toggle`.
- Body (optional): the *why*, not the *what*. The diff already shows the what.

### PR checklist

- [ ] Builds cleanly: `swift build -c release`
- [ ] Runs and behaves as expected on macOS 14+
- [ ] UI changes include a screenshot or short GIF
- [ ] README / README.ja.md updated if user-visible behavior changed
- [ ] No new dependencies (or, if so, explained in the PR description)

### Good first issues

The README "Contributing" section lists open ideas. A **launch-at-login toggle** or a **time-range filter** are nice self-contained starters.

---

<a id="ja"></a>

## 日本語

### 心構え

- **やさしく。** [Contributor Covenant](https://www.contributor-covenant.org/) の精神に沿って、Issue / PR / レビューで敬意を持って接してください。
- **1 PR 1 トピック。** 小さく焦点が絞られた PR の方が早くマージできます。
- **大きな変更は先に相談。** UX やアーキテクチャを変えるような機能は、コードを書く前に Issue を立てて方向性を合わせましょう。

### 開発環境のセットアップ

```bash
git clone https://github.com/akidon0000/claude-usage-menubar.git
cd claude-usage-menubar

swift build            # デバッグビルド
swift run -c release   # ソースから実行
./build.sh             # Claude Usage.app をパッケージして /Applications にインストール
```

アプリは `~/.claude/usage/<org>/<repo>.json` を読みます。実ログが無い場合は、サンプル JSON を置けば UI を確認できます。

### コーディングスタイル

- SwiftUI + Swift Concurrency。UI に触る状態は `@MainActor` に置く。
- パースと集計は `UsageStore` に集約（SSOT）。`PopoverView` は純粋な表示層に保つ。
- 依存パッケージは原則追加しない（ビルドを最小に保ちたい）。
- ファイル配置は既存の [`ClaudeUsageMenubar/Sources/`](ClaudeUsageMenubar/Sources/) に揃える。

### コミットメッセージ

- Subject: 命令形・72 文字未満。例: `Add launch-at-login toggle`
- Body（任意）: *何をしたか* ではなく *なぜそうしたか* を書く。差分を見れば「何」は分かるので。

### PR チェックリスト

- [ ] ビルドが通る: `swift build -c release`
- [ ] macOS 14+ で意図どおりに動く
- [ ] UI 変更はスクリーンショットか短い GIF を添付
- [ ] ユーザーから見える変更があれば README / README.ja.md も更新
- [ ] 新規依存は追加しない（追加する場合は PR 本文で理由を説明）

### 最初の一歩におすすめ

README の「コントリビュート」セクションにアイデアを並べています。「ログイン時起動トグル」や「期間フィルタ」は単体で完結しやすい初手としておすすめです。
