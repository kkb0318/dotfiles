# Nix / Home Manager

MacとWSL内の開発環境を管理する。Go・Python・Fish・tmux・Neovim本体はNix、プラグインはLazy / Fisherで管理する。

## セットアップ

Nixをインストールし、`nix-command flakes`を有効にする。リポジトリを取得したら、`hosts/`のユーザー名・ホームディレクトリと、`flake.nix`のCPUアーキテクチャを環境に合わせる。

リポジトリのルートで実行する。

```sh
# ビルド確認
bash setup.sh --nix personal-mac --build-only

# パッケージ適用・設定配置・固定プラグインの復元
bash setup.sh --nix personal-mac
```

| 構成 | OS | 用途 |
|---|---|---|
| `personal-mac` | macOS / Apple Silicon | 私用 |
| `work-mac` | macOS / Apple Silicon | 社用 |
| `personal-wsl` | WSL / x86_64 Linux | 私用 |
| `work-wsl` | WSL / x86_64 Linux | 社用 |

Fish・Neovim・tmuxの設定をチェックアウトへリンクする。別の設定がある場合は上書きせず停止する。適用後はFishを起動し直す。ログインシェル、Windowsホスト、OSサービスの設定は変更しない。

## パッケージの追加

- `modules/common.nix`: 全端末で使うパッケージと設定。
- `modules/work.nix`: 社用のみの追加。
- `modules/personal.nix`: 私用のみの追加。
- `modules/platforms/`: OS固有の設定。
- `hosts/`: 端末ごとの組み合わせとアカウント情報。

社用・私用は初期状態では同じ構成。用途別ファイルの`home.packages`に追加すると、共通構成へ合成される。

```nix
{ pkgs, ... }: {
  home.packages = [ pkgs.google-cloud-sdk ];
}
```

共通構成には本体5種に加え、Git・curl・fzf・ghq・ripgrep・gopls・ruff・direnvを含む。

## 更新と復元

```fish
update-nix personal-mac --build-only
update-nix personal-mac
update-nix  # 最後に適用した構成を使用
```

`update-nix`は既存の`flake.lock`からパッケージだけを適用する。新しいバージョンの選定は行わない。初回導入を含むプラグインの復元は次を使う。

```sh
python3 scripts/bootstrap-plugins.py --check
python3 scripts/bootstrap-plugins.py
```

プラグインは`fish/fish_plugins`と`nvim/lua/plugins/lazy-lock.json`のコミットへ固定する。Lazyの追加・削除時は取得元一覧`nvim/plugin-sources.json`も更新する。通常起動時の不足プラグイン取得とMasonの自動インストールは無効。

Neovimプラグインのネイティブビルドは自動実行しない。LuaSnipのjsregexpやMarkdown Previewなどは依存とビルド手順を別途確認する。Fisherのインストールフックは実行する。

Nixのロールバックではプラグインは戻らないため、対応するGit revisionから復元する。更新候補の7日待機と固定方法は[更新方針](../docs/updates.md)を参照。

## 検証

```sh
python3 -m unittest discover -s tests -p 'test_*.py'
bash setup.sh --nix personal-mac --build-only
```

Macでビルドと隔離環境でのプラグイン復元・起動を確認済み。WSLは構成評価までで、実機検証は未実施。
