# パッケージ更新

パッケージはNix、Fish / Neovimプラグインは固定したコミットから適用する。適用時に最新版を選定しない。

```fish
update-nix personal-mac --build-only
update-nix personal-mac
update --dry-run
update
```

`update-nix`は既存の`home-manager/flake.lock`を適用する。初回セットアップは`bash scripts/setup-nix.sh <構成名>`を使う。詳細は[セットアップ手順](../home-manager/README.md)を参照。

`update`は導入済みFisher / Lazyプラグインを復元する。`--dry-run`は適用先を表示するだけで、取得・変更をしない。失敗や不正な固定情報は終了コード1、引数の誤りは2。未導入の管理ツールはスキップする。

## 更新候補の選択

- RenovateのNix managerでflake入力の更新を扱う。Nixの自動マージは無効。
- `minimumReleaseAge: "7 days"`、`timestamp-required`、`internalChecksFilter: "strict"`を維持する。Renovateが稼働し、候補の公開日時を取得できる必要がある。日時を取得できない候補は保留する。
- Nixpkgs入力の経過日数だけでは、その中の全パッケージの公開後7日を保証できない。上流の公開日時も確認し、不明なものを自動承認しない。
- Fish / NeovimのSHAはRenovateの自動管理対象外。公開日時・差分を確認して固定ファイルを更新する。リリースがない場合は候補SHAを記録してから7日以上保留する。コミット日時だけを公開日時の根拠にしない。
- 脆弱性対応も7日待機・自動マージ無効を基本とし、緊急時の例外は個別に判断する。

ローカル適用時には公開日時を再取得しない。7日待機は候補を採用する工程で守る方針であり、安全性を保証するものではない。既知の悪意ある版や撤回された版は採用しない。

## 固定するファイル

| 対象 | ファイル |
|---|---|
| Nixpkgs / Home Manager | `home-manager/flake.lock` |
| Fisher本体とFishプラグイン | `fish/fish_plugins`（完全なコミットSHA） |
| lazy.nvim本体とNeovimプラグイン | `nvim/lua/plugins/lazy-lock.json` |
| Neovimプラグインの取得元 | `nvim/plugin-sources.json` |

Fisherは有効な`fish_plugins`がこのリポジトリを指すことを確認する。取得の失敗や一覧の部分的な書き換えを検出し、元の一覧を維持する。

Neovimの復元では通常の設定、プラグインのinit/config、ビルドフックを実行しない。取得済みlazy.nvimが固定SHAと異なる場合は停止する。初回導入・未導入プラグイン・管理ツール自身の更新には次を使う。

```sh
python3 scripts/bootstrap-plugins.py --check
python3 scripts/bootstrap-plugins.py
```

LuaSnipのjsregexpやMarkdown Preview等、追加ビルドが必要な機能は依存と取得元を確認して別途ビルドする。通常起動時のLazyの不足プラグイン取得とMasonの自動導入は無効。

Homebrew、Krew、Rustup/Cargo、Go、Volta、pyenv、Masonの一括更新は`update`から呼ばない。追加ツールは用途別Nixモジュールやプロジェクトの環境で管理する。

参照: [Renovate Nix manager](https://docs.renovatebot.com/modules/manager/nix/)、[旧セットアップの移行表](legacy-setup-migration.md)。
