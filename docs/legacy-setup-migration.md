# 旧セットアップからの移行

セットアップの入口は`bash scripts/setup-nix.sh <構成名>`に統一した。ルートの`setup.sh`、Aqua設定・インストーラ・PATH設定、`rhysd/dotfiles`への依存は削除した。

## 対応表

| 旧処理 | 移行先・扱い |
|---|---|
| Homebrew / apt / yumによるFish・curl・Neovim導入 | `home-manager/modules/common.nix` |
| Aquaのripgrep・fzf・ghq | 共通Nixパッケージ。既に移行済み |
| Aquaのlazygit・peco | 共通Nixパッケージへ追加 |
| AquaのDeno | 不要になったため廃止。残っていたNeovimのDeno LSP設定も削除 |
| Aquaのrhysd/dotfiles / `dotfiles link .` | `config-links.json`とPythonの設定リンク処理へ置換 |
| Fish / Neovim / tmuxの設定リンク | 全OS共通。書き込み可能なチェックアウトへリンク |
| Bash / Git / Lazygit / peco / Nix / Home Managerの設定リンク | 全OS共通のリンクに追加。`XDG_CONFIG_HOME`を尊重 |
| AeroSpace / WezTerm / Ghosttyの設定リンク | Macのみ。アプリ本体はこの移行では追加しない |
| macOSのFinder / Dock / ファイル表示設定 | `modules/platforms/darwin.nix`のHome Manager defaultsへ移行 |
| 最新版Fisherを取得・実行 | SHA固定のbootstrapへ移行済み |
| Fishの補完生成 | 新セットアップのプラグイン復元後に実行 |
| Aquaの更新・チェックサム処理 | 廃止。パッケージは`update-nix`、プラグインは`update` |
| RenovateのAqua preset | 削除しNix managerを有効化。Nix入力の自動マージは無効 |
| Command Line Tools / Rosetta / ログインシェル変更 | OS側の任意手順として分離（下記） |
| SDKROOTの設定 | Nixビルドにはグローバル設定しない。Xcodeを使うプロジェクト側で必要に応じて設定 |

パッケージのバージョンは既存の`home-manager/flake.lock`に従う。旧Aquaのバージョンと一致するとは限らない。lock自体はこの移行で更新していない。

## OS側の任意手順

Nix・Gitと、WSLの場合はWSL2 / Linuxを先に用意する。従来のLinuxディストリビューション別インストーラは廃止した。

MacでAppleの開発ツールやIntel用アプリが必要な場合のみ実行する。

```sh
xcode-select --install
# Apple SiliconでIntel用アプリを使用する場合
softwareupdate --install-rosetta --agree-to-license
```

macOSのユーザー設定はHome Manager適用時に反映される。表示への反映にはFinder / Dockの再起動または再ログインが必要な場合がある。実行中のアプリはセットアップから強制終了しない。
`update-nix`や`--packages-only`でもHome Managerの設定は適用される。`--packages-only`が省略するのは設定リンクの作成とプラグイン復元・補完生成。

Fishをログインシェルにする場合は、Nix構成を適用した後にBash等から実行する。

```sh
fish_shell="$HOME/.nix-profile/bin/fish"
test -x "$fish_shell" || exit 1
if ! grep -Fxq "$fish_shell" /etc/shells; then
  printf '%s\n' "$fish_shell" | sudo tee -a /etc/shells
fi
chsh -s "$fish_shell"
```

ログインシェルに指定している間は、そのNix profileとFishを維持する。

## 既存端末の切り替え

1. `bash scripts/setup-nix.sh <構成名> --build-only`でビルドする。
2. `python3 scripts/bootstrap-plugins.py --check`で配置先を確認する。既存の`.bashrc`等と衝突する場合は必要な内容を統合・退避する。自動上書きはしない。
3. `bash scripts/setup-nix.sh <構成名>`で適用し、新しいシェルで`command -v fish nvim rg fzf ghq lazygit peco`がNix profileを指すことを確認する。
4. 以前Fishのuniversal変数へ追加したAquaのPATHが残っている場合は、そのエントリだけを取り除く。既存のシェルにも古い環境変数が残り得るため、ログインし直す。
5. 他のリポジトリでAquaを使用していないことを確認してから、Aqua本体・キャッシュと旧設定リンクを削除する。

この変更で既存端末のHomebrew・Aquaのインストール実体やキャッシュは削除しない。Homebrewで管理中の、今回対象外のアプリにも影響させない。
